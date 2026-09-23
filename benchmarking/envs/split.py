#!/usr/bin/env python3
"""Generate benchmark instances by sub-sampling the trains of a base environment.

The topology and every other fact of the base environment are kept; only the
facts of trains that are not selected are removed. For each train count k in
[--min, --max], up to --n distinct train subsets are drawn uniformly at random.

    python gen.py envs/Test_03/Level_3.lp --min=2 --max=50 --n=10 --seed=123

Output goes to gen/<parent-dir>/<stem>/ (here gen/Test_03/Level_3/):

    <k>-<mask>.lp    one instance; mask = sum of 2**i over the selected train IDs,
                     e.g. trains 5 and 6 -> 2**5 + 2**6 = 96 -> 2-96.lp
    manifest.json    seed, arguments, base-file hash, and the train list of
                     every instance

Decode a mask with mask_to_trains(), or in one line:
    [i for i in range(N) if mask >> i & 1]

Reproducibility: each bin k draws from its own RNG derived from (seed, k), so
bin k is identical whatever --min/--max are. Subsets within a bin are drawn
sequentially without replacement, so raising --n keeps the first --n subsets
of the smaller run. If no --seed is given, one is drawn and recorded.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import re
import secrets
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

import clingo

Signature = tuple[str, int]

TRAIN: Signature = ("train", 1)
END: Signature = ("end", 3)          # end(Train, Cell, Time)
HORIZON: Signature = ("global", 1)   # global(Time)
REQUIRED_PER_TRAIN: tuple[Signature, ...] = (("start", 4), ("end", 3))
DEFAULT_TRAIN_PREDS = "train/1,start/4,end/3,speed/2"

MANIFEST = "manifest.json"
INSTANCE_NAME = re.compile(r"^\d+-\d+\.lp$")


class GenError(Exception):
    """A user-facing error: bad input, bad arguments, or unsafe output path."""


# --------------------------------------------------------------------------
# Reading the base environment
# --------------------------------------------------------------------------

@dataclass
class Environment:
    num_trains: int
    horizon: list[clingo.Symbol]              # global/1 facts, as in the base file
    train_facts: list[list[clingo.Symbol]]    # per train ID, in --train-preds order
    train_end: list[int | None]               # max end time per train, if numeric
    static: list[list[clingo.Symbol]]         # every other fact, grouped by signature


def signature(sym: clingo.Symbol) -> Signature:
    return (sym.name, len(sym.arguments))


def fmt_sig(sig: Signature) -> str:
    return f"{sig[0]}/{sig[1]}"


def load_facts(path: Path) -> list[clingo.Symbol]:
    """Ground the base file on its own and return its facts."""
    ctl = clingo.Control(["--warn=none"])
    try:
        ctl.load(str(path))
        ctl.ground([("base", [])])
    except RuntimeError as err:
        raise GenError(f"clingo could not load {path}: {err}") from err

    facts, undecided = [], []
    for atom in ctl.symbolic_atoms:
        (facts if atom.is_fact else undecided).append(atom.symbol)
    if undecided:
        sample = ", ".join(str(s) for s in undecided[:3])
        raise GenError(
            f"{path} does not reduce to facts ({len(undecided)} undecided atoms, "
            f"e.g. {sample}); the base environment must be deterministic"
        )
    return facts


def build_environment(facts: Sequence[clingo.Symbol],
                      train_preds: Sequence[Signature]) -> Environment:
    by_sig: dict[Signature, list[clingo.Symbol]] = defaultdict(list)
    for sym in facts:
        by_sig[signature(sym)].append(sym)

    # Train IDs must be exactly 0..N-1, since the file-name mask relies on it.
    ids = []
    for sym in by_sig.get(TRAIN, []):
        arg = sym.arguments[0]
        if arg.type != clingo.SymbolType.Number:
            raise GenError(f"non-integer train ID in {sym}")
        ids.append(arg.number)
    if not ids:
        raise GenError("the base file contains no train/1 facts")
    n = len(ids)
    if sorted(ids) != list(range(n)):
        if min(ids) < 0:
            raise GenError(f"negative train ID {min(ids)}; IDs must start at 0")
        missing = sorted(set(range(max(ids) + 1)) - set(ids))
        raise GenError(
            f"train IDs must be contiguous from 0, but the highest is "
            f"{max(ids)} and IDs {missing[:10]} are missing"
        )

    # Collect each train's facts; they are dropped when the train is not selected.
    train_facts: list[list[clingo.Symbol]] = [[] for _ in range(n)]
    present: list[set[Signature]] = [set() for _ in range(n)]
    for sig in train_preds:
        for sym in sorted(by_sig.pop(sig, [])):
            arg = sym.arguments[0]
            if arg.type != clingo.SymbolType.Number or not 0 <= arg.number < n:
                raise GenError(f"{sym} does not refer to a train ID in 0..{n - 1}")
            train_facts[arg.number].append(sym)
            present[arg.number].add(sig)

    for sig in REQUIRED_PER_TRAIN:
        lacking = [z for z in range(n) if sig not in present[z]]
        if lacking:
            raise GenError(f"trains {lacking[:10]} have no {fmt_sig(sig)} fact")

    train_end: list[int | None] = [None] * n
    for z in range(n):
        times = [s.arguments[2] for s in train_facts[z] if signature(s) == END]
        if times and all(t.type == clingo.SymbolType.Number for t in times):
            train_end[z] = max(t.number for t in times)

    horizon = sorted(by_sig.pop(HORIZON, []))

    # A pass-through predicate whose first argument always looks like a train ID
    # is probably train-indexed and missing from --train-preds.
    for sig, syms in by_sig.items():
        if sig[1] >= 2 and all(
            s.arguments[0].type == clingo.SymbolType.Number
            and 0 <= s.arguments[0].number < n
            for s in syms
        ):
            print(
                f"warning: {fmt_sig(sig)} is kept for every instance, but its first "
                f"argument always looks like a train ID; if it is per-train, "
                f"add it to --train-preds",
                file=sys.stderr,
            )

    static = [sorted(by_sig[sig]) for sig in sorted(by_sig)]
    return Environment(n, horizon, train_facts, train_end, static)


# --------------------------------------------------------------------------
# Sampling
# --------------------------------------------------------------------------

@dataclass
class Bin:
    k: int
    requested: int
    available: int                 # C(N, k)
    subsets: list[tuple[int, ...]]  # in draw order


def bin_rng(seed: int, k: int) -> random.Random:
    """Independent, reproducible RNG for bin k."""
    digest = hashlib.sha256(f"{seed}:{k}".encode()).digest()
    return random.Random(int.from_bytes(digest, "big"))


def draw_ranks(rng: random.Random, total: int, m: int) -> list[int]:
    """Draw min(m, total) distinct integers uniformly from range(total), in draw order.

    Sequential draws without replacement: a prefix of the result is itself a
    uniform sample, so a larger m extends a smaller one. Rejection is cheap
    because m is only close to total when total itself is small.
    """
    if m >= total:
        return list(range(total))
    chosen: dict[int, None] = {}   # insertion-ordered set
    while len(chosen) < m:
        chosen.setdefault(rng.randrange(total))
    return list(chosen)


def unrank(rank: int, k: int) -> tuple[int, ...]:
    """The k-subset of {0, 1, ...} with the given colex rank.

    Combinatorial number system: rank = sum_i C(c_i, i) for c_1 < ... < c_k.
    Colex order on k-subsets coincides with numeric order of their bitmasks.
    """
    subset = []
    for i in range(k, 0, -1):
        c = i - 1
        while math.comb(c + 1, i) <= rank:
            c += 1
        rank -= math.comb(c, i)
        subset.append(c)
    return tuple(reversed(subset))


def plan(num_trains: int, kmin: int, kmax: int, n: int, seed: int) -> list[Bin]:
    bins = []
    for k in range(kmin, kmax + 1):
        total = math.comb(num_trains, k)
        ranks = draw_ranks(bin_rng(seed, k), total, n)
        bins.append(Bin(k, n, total, [unrank(r, k) for r in ranks]))
    return bins


def trains_to_mask(trains: Sequence[int]) -> int:
    return sum(1 << z for z in trains)


def mask_to_trains(mask: int) -> list[int]:
    return [z for z in range(mask.bit_length()) if mask >> z & 1]


# --------------------------------------------------------------------------
# Writing
# --------------------------------------------------------------------------

class Renderer:
    """Pre-renders the fixed parts once; each instance just joins strings."""

    def __init__(self, env: Environment, horizon_mode: str):
        self.env = env
        self.horizon_mode = horizon_mode
        self.horizon_text = "".join(f"{s}.\n" for s in env.horizon)
        self.train_lines = [
            " ".join(f"{s}." for s in facts) + "\n" for facts in env.train_facts
        ]
        self.static_text = "".join(
            "\n" + "".join(f"{s}.\n" for s in group) for group in env.static
        )

    def __call__(self, subset: Sequence[int]) -> str:
        if self.horizon_mode == "max-end":
            horizon = f"{HORIZON[0]}({max(self.env.train_end[z] for z in subset)}).\n"
        else:
            horizon = self.horizon_text
        trains = "".join(self.train_lines[z] for z in subset)
        return horizon + "\n" + trains + self.static_text


def default_out(base: Path) -> Path:
    return Path("gen") / base.parent.name / base.stem


def prepare_out(out: Path, force: bool) -> None:
    if out.exists() and not out.is_dir():
        raise GenError(f"{out} exists and is not a directory")
    if out.is_dir():
        existing = list(out.iterdir())
        if existing and not force:
            raise GenError(f"{out} is not empty; pass --force to replace its instances")
        stray = [p.name for p in existing
                 if not (INSTANCE_NAME.match(p.name) or p.name == MANIFEST)]
        if stray:
            raise GenError(
                f"{out} contains files this script did not create "
                f"({', '.join(stray[:5])}); refusing to delete anything"
            )
        for p in existing:
            p.unlink()
    out.mkdir(parents=True, exist_ok=True)


def file_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


# --------------------------------------------------------------------------
# Command line
# --------------------------------------------------------------------------

def positive_int(text: str) -> int:
    value = int(text)
    if value < 1:
        raise argparse.ArgumentTypeError(f"must be at least 1, got {value}")
    return value


def signature_list(text: str) -> list[Signature]:
    sigs = []
    for item in text.split(","):
        m = re.fullmatch(r"\s*([a-z_][A-Za-z0-9_']*)/(\d+)\s*", item)
        if not m:
            raise argparse.ArgumentTypeError(f"expected name/arity, got {item!r}")
        sigs.append((m[1], int(m[2])))
    if TRAIN not in sigs:
        raise argparse.ArgumentTypeError("must include train/1")
    return sigs


def parse_args(argv: Sequence[str] | None) -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Sub-sample the trains of a base environment into benchmark bins.",
    )
    p.add_argument("base", type=Path, help="base environment (.lp)")
    p.add_argument("--min", dest="kmin", type=positive_int, required=True,
                   help="smallest number of selected trains")
    p.add_argument("--max", dest="kmax", type=positive_int, required=True,
                   help="largest number of selected trains")
    p.add_argument("--n", type=positive_int, required=True,
                   help="instances per train count (capped at C(N, k))")
    p.add_argument("--seed", type=int, default=None,
                   help="random seed (drawn and recorded if omitted)")
    p.add_argument("--out", type=Path, default=None,
                   help="output directory (default: gen/<parent-dir>/<stem>)")
    p.add_argument("--force", action="store_true",
                   help="replace instances in a non-empty output directory")
    p.add_argument("--horizon", choices=("keep", "max-end"), default="keep",
                   help="keep the base global/1 (default) or set it to the "
                        "latest end time of the selected trains")
    p.add_argument("--train-preds", type=signature_list,
                   default=signature_list(DEFAULT_TRAIN_PREDS),
                   help=f"per-train predicates, first argument = train ID "
                        f"(default: {DEFAULT_TRAIN_PREDS})")
    args = p.parse_args(argv)
    if args.kmin > args.kmax:
        p.error(f"--min ({args.kmin}) is larger than --max ({args.kmax})")
    return args


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        if not args.base.is_file():
            raise GenError(f"{args.base} does not exist")
        env = build_environment(load_facts(args.base), args.train_preds)
        if args.kmax > env.num_trains:
            raise GenError(
                f"--max={args.kmax} but {args.base} has only {env.num_trains} "
                f"trains (train(0)..train({env.num_trains - 1}))"
            )
        if args.horizon == "max-end" and None in env.train_end:
            raise GenError("--horizon=max-end needs a numeric end time for every train")

        seed_given = args.seed is not None
        seed = args.seed if seed_given else secrets.randbelow(2**32)
        bins = plan(env.num_trains, args.kmin, args.kmax, args.n, seed)

        out = args.out or default_out(args.base)
        prepare_out(out, args.force)
        render = Renderer(env, args.horizon)

        instances = []
        for b in bins:
            for draw, subset in enumerate(b.subsets):
                mask = trains_to_mask(subset)
                name = f"{b.k}-{mask}.lp"
                (out / name).write_text(render(subset))
                instances.append({"file": name, "k": b.k, "draw": draw,
                                  "mask": mask, "trains": list(subset)})

        manifest = {
            "base": str(args.base),
            "base_sha256": file_sha256(args.base),
            "num_trains": env.num_trains,
            "seed": seed,
            "seed_generated": not seed_given,
            "min": args.kmin, "max": args.kmax, "n": args.n,
            "horizon": args.horizon,
            "train_preds": [fmt_sig(s) for s in args.train_preds],
            "bins": [{"k": b.k, "requested": b.requested, "available": b.available,
                      "generated": len(b.subsets)} for b in bins],
            "instances": instances,
        }
        (out / MANIFEST).write_text(json.dumps(manifest, indent=1) + "\n")
    except GenError as err:
        print(f"error: {err}", file=sys.stderr)
        return 2

    print(f"{len(instances)} instances from {env.num_trains} trains -> {out}/")
    print(f"seed {seed}" + ("" if seed_given else " (generated)"))
    short = [b for b in bins if len(b.subsets) < b.requested]
    for b in short:
        print(f"note: k={b.k} has only {b.available} possible subset(s); "
              f"generated all of them")
    return 0


if __name__ == "__main__":
    sys.exit(main())
