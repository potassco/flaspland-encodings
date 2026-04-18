#!/usr/bin/env python3
"""
flasp-min-horizon: find the minimum horizon constant that produces SAT for a
set of Flatland ASP instances.

Strategy: exponential probe from a starting guess, then binary search.

Assumes SAT is monotone in the horizon constant (if h=k is SAT, so is h=k+1).
If your encoding violates this (e.g., "arrive at exactly step h" rather than
"arrive by step h"), binary search results will be incorrect; use linear
search elsewhere.

Example:
    flasp-min-horizon encoding.lp preprocessing.lp \\
        --instances benchmarks/ \\
        --guess 40 \\
        --timeout 60 \\
        --jobs 4 \\
        --output results.csv
"""

from __future__ import annotations

import argparse
import concurrent.futures
import csv
import glob
import json
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------

@dataclass
class SolveResult:
    """Outcome of a single clingo call at a specific horizon.

    wall_time:     Python-measured subprocess wall time (includes process startup).
    clingo_total:  clingo's self-reported Time.Total (grounding + solving + I/O).
    clingo_solve:  clingo's self-reported Time.Solve (solving only).
    grounding := clingo_total - clingo_solve.
    """
    status: str  # "SAT", "UNSAT", "TIMEOUT", "ERROR"
    wall_time: float
    clingo_total: Optional[float] = None
    clingo_solve: Optional[float] = None
    stderr: str = ""


@dataclass
class InstanceResult:
    """Outcome of searching for the minimum horizon on one instance."""
    instance: str
    min_horizon: Optional[int]
    solve_time_at_min: Optional[float]       # wall time (kept for backward compat)
    clingo_total_at_min: Optional[float] = None
    clingo_solve_at_min: Optional[float] = None
    status: str = "FOUND"  # "FOUND", "NO_SAT_UP_TO_HMAX", "ERROR"
    message: str = ""
    trace: list[tuple[int, str, float]] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Clingo invocation
# ---------------------------------------------------------------------------

def run_clingo(
    encodings: list[str],
    instance: str,
    horizon: int,
    const_name: str,
    timeout: float,
    clingo_bin: str,
    extra_args: list[str],
) -> SolveResult:
    """Invoke clingo once at the given horizon; parse SAT/UNSAT from JSON output."""
    cmd = [
        clingo_bin,
        *encodings,
        instance,
        f"-c", f"{const_name}={horizon}",
        "--outf=2",
        *extra_args,
    ]

    start = time.perf_counter()
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,  # clingo uses non-zero exit codes to signal SAT/UNSAT
        )
    except subprocess.TimeoutExpired:
        return SolveResult(status="TIMEOUT", wall_time=timeout)
    except FileNotFoundError:
        return SolveResult(
            status="ERROR",
            wall_time=0.0,
            stderr=f"clingo binary not found: {clingo_bin}",
        )
    wall = time.perf_counter() - start

    # Parse JSON output (--outf=2). The "Result" field is "SATISFIABLE",
    # "UNSATISFIABLE", or "UNKNOWN". The "Time" object provides "Total",
    # "Solve", "Model", "Unsat", and "CPU" fields.
    try:
        data = json.loads(proc.stdout)
        result = data.get("Result", "UNKNOWN")
        time_info = data.get("Time", {}) or {}
        clingo_total = time_info.get("Total")
        clingo_solve = time_info.get("Solve")
    except json.JSONDecodeError:
        return SolveResult(
            status="ERROR",
            wall_time=wall,
            stderr=f"could not parse clingo output:\n{proc.stdout[:500]}\n"
                   f"stderr:\n{proc.stderr[:500]}",
        )

    if result == "SATISFIABLE":
        return SolveResult(
            status="SAT", wall_time=wall,
            clingo_total=clingo_total, clingo_solve=clingo_solve,
        )
    elif result == "UNSATISFIABLE":
        return SolveResult(
            status="UNSAT", wall_time=wall,
            clingo_total=clingo_total, clingo_solve=clingo_solve,
        )
    else:
        return SolveResult(
            status="ERROR",
            wall_time=wall,
            clingo_total=clingo_total, clingo_solve=clingo_solve,
            stderr=f"clingo returned result={result!r}",
        )


# ---------------------------------------------------------------------------
# Search
# ---------------------------------------------------------------------------

def find_min_horizon(
    encodings: list[str],
    instance: str,
    guess: int,
    h_min: int,
    h_max: int,
    const_name: str,
    timeout: float,
    clingo_bin: str,
    extra_args: list[str],
) -> InstanceResult:
    """Find the minimum horizon at which `instance` is SAT.

    Phase 1 (probing): expand until we bracket the answer with one UNSAT and
    one SAT horizon.
    Phase 2 (binary search): shrink the bracket to find the smallest SAT value.
    """
    trace: list[tuple[int, str, float]] = []
    # Cache results so binary search never re-solves a horizon.
    cache: dict[int, SolveResult] = {}

    def solve(h: int) -> SolveResult:
        if h in cache:
            return cache[h]
        res = run_clingo(
            encodings, instance, h, const_name, timeout, clingo_bin, extra_args
        )
        cache[h] = res
        trace.append((h, res.status, res.wall_time))
        return res

    # Start at the guess, clamped to bounds.
    start = max(h_min, min(guess, h_max))
    first = solve(start)

    if first.status in ("TIMEOUT", "ERROR"):
        return InstanceResult(
            instance=instance,
            min_horizon=None,
            solve_time_at_min=None,
            status="ERROR",
            message=f"initial probe at h={start} failed: {first.status} "
                    f"({first.stderr.strip() if first.stderr else ''})",
            trace=trace,
        )

    # ------- Phase 1: bracket the answer -------
    # We want two values: low (UNSAT) and high (SAT), with low < high.
    # Special case: low can be "below h_min" (meaning h_min itself is SAT).

    low: Optional[int] = None   # highest known UNSAT, or None if h_min is SAT
    high: Optional[int] = None  # lowest known SAT, or None if no SAT found yet

    if first.status == "SAT":
        high = start
        # Walk down by halving until UNSAT or we hit h_min.
        probe = start
        while True:
            next_probe = max(h_min, probe // 2)
            if next_probe == probe:
                # Can't go lower; check h_min explicitly if we haven't.
                if h_min not in cache:
                    r = solve(h_min)
                    if r.status == "SAT":
                        high = h_min
                        low = None  # h_min itself is SAT; answer is h_min.
                    elif r.status == "UNSAT":
                        low = h_min
                    else:
                        return InstanceResult(
                            instance=instance, min_horizon=None,
                            solve_time_at_min=None, status="ERROR",
                            message=f"h={h_min} returned {r.status}",
                            trace=trace,
                        )
                break
            r = solve(next_probe)
            if r.status == "SAT":
                high = next_probe
                probe = next_probe
            elif r.status == "UNSAT":
                low = next_probe
                break
            else:
                return InstanceResult(
                    instance=instance, min_horizon=None,
                    solve_time_at_min=None, status="ERROR",
                    message=f"probe at h={next_probe} returned {r.status}",
                    trace=trace,
                )
    else:  # first.status == "UNSAT"
        low = start
        probe = start
        while True:
            next_probe = min(h_max, max(probe * 2, probe + 1))
            if next_probe == probe:
                # We're at h_max and it was UNSAT; check h_max if we haven't.
                # (We have, since probe == h_max means we already solved it.)
                return InstanceResult(
                    instance=instance, min_horizon=None,
                    solve_time_at_min=None, status="NO_SAT_UP_TO_HMAX",
                    message=f"UNSAT at all tested horizons up to h_max={h_max}",
                    trace=trace,
                )
            r = solve(next_probe)
            if r.status == "UNSAT":
                low = next_probe
                probe = next_probe
                if next_probe == h_max:
                    return InstanceResult(
                        instance=instance, min_horizon=None,
                        solve_time_at_min=None, status="NO_SAT_UP_TO_HMAX",
                        message=f"UNSAT at h_max={h_max}",
                        trace=trace,
                    )
            elif r.status == "SAT":
                high = next_probe
                break
            else:
                return InstanceResult(
                    instance=instance, min_horizon=None,
                    solve_time_at_min=None, status="ERROR",
                    message=f"probe at h={next_probe} returned {r.status}",
                    trace=trace,
                )

    # ------- Phase 2: binary search -------
    # Invariant: if low is None, answer = h_min (which is SAT).
    # Otherwise, answer is in (low, high], and we know h=low is UNSAT, h=high is SAT.
    if low is None:
        assert high is not None
        min_h = high
    else:
        assert high is not None and low < high
        while high - low > 1:
            mid = (low + high) // 2
            r = solve(mid)
            if r.status == "SAT":
                high = mid
            elif r.status == "UNSAT":
                low = mid
            else:
                return InstanceResult(
                    instance=instance, min_horizon=None,
                    solve_time_at_min=None, status="ERROR",
                    message=f"binary search at h={mid} returned {r.status}",
                    trace=trace,
                )
        min_h = high

    best = cache[min_h]
    return InstanceResult(
        instance=instance,
        min_horizon=min_h,
        solve_time_at_min=best.wall_time,
        clingo_total_at_min=best.clingo_total,
        clingo_solve_at_min=best.clingo_solve,
        status="FOUND",
        trace=trace,
    )


# ---------------------------------------------------------------------------
# Instance discovery
# ---------------------------------------------------------------------------

def discover_instances(instances_arg: str) -> list[str]:
    """Expand a directory or glob into a sorted list of instance file paths."""
    path = Path(instances_arg)
    if path.is_dir():
        files = sorted(path.glob("*.lp"))
    else:
        files = sorted(Path(p) for p in glob.glob(instances_arg))
    return [str(f) for f in files]


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Find the minimum horizon constant that yields SAT for "
                    "Flatland ASP instances.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "encodings", nargs="+",
        help="One or more ASP encoding files (e.g., preprocessing.lp routing.lp).",
    )
    parser.add_argument(
        "--instances", required=True,
        help="Directory containing *.lp instance files, or a glob pattern.",
    )
    parser.add_argument(
        "--const-name", default="h",
        help="Name of the horizon constant in the encoding (default: h).",
    )
    parser.add_argument(
        "--guess", type=int, default=30,
        help="Starting horizon for probing (default: 30).",
    )
    parser.add_argument(
        "--h-min", type=int, default=1,
        help="Minimum horizon to consider (default: 1).",
    )
    parser.add_argument(
        "--h-max", type=int, default=1000,
        help="Maximum horizon to consider (default: 1000).",
    )
    parser.add_argument(
        "--timeout", type=float, default=120.0,
        help="Per-solve timeout in seconds (default: 120).",
    )
    parser.add_argument(
        "--jobs", type=int, default=1,
        help="Number of instances to process in parallel (default: 1). "
             "Each instance's search is sequential.",
    )
    parser.add_argument(
        "--clingo", default="clingo",
        help="Path to the clingo binary (default: clingo).",
    )
    parser.add_argument(
        "--clingo-arg", action="append", default=[],
        help="Extra argument passed through to clingo. Repeatable. "
             "Example: --clingo-arg=--parallel-mode=4",
    )
    parser.add_argument(
        "--output", "-o",
        help="Write CSV results to this file (default: stdout).",
    )
    parser.add_argument(
        "--quiet", action="store_true",
        help="Suppress per-instance progress messages on stderr.",
    )
    args = parser.parse_args()

    # Validate
    if args.h_min < 1:
        parser.error("--h-min must be >= 1")
    if args.h_max < args.h_min:
        parser.error("--h-max must be >= --h-min")
    if args.guess < args.h_min or args.guess > args.h_max:
        parser.error(f"--guess must be within [--h-min, --h-max] "
                     f"(got {args.guess}, bounds [{args.h_min}, {args.h_max}])")

    for enc in args.encodings:
        if not Path(enc).is_file():
            parser.error(f"encoding file not found: {enc}")

    instances = discover_instances(args.instances)
    if not instances:
        parser.error(f"no instances found matching: {args.instances}")

    if not args.quiet:
        print(f"# encodings: {' '.join(args.encodings)}", file=sys.stderr)
        print(f"# instances: {len(instances)} found", file=sys.stderr)
        print(f"# search: guess={args.guess}, bounds=[{args.h_min}, {args.h_max}], "
              f"timeout={args.timeout}s, jobs={args.jobs}", file=sys.stderr)

    # Dispatch
    def work(instance: str) -> InstanceResult:
        return find_min_horizon(
            encodings=args.encodings,
            instance=instance,
            guess=args.guess,
            h_min=args.h_min,
            h_max=args.h_max,
            const_name=args.const_name,
            timeout=args.timeout,
            clingo_bin=args.clingo,
            extra_args=args.clingo_arg,
        )

    results: list[InstanceResult] = []
    if args.jobs == 1:
        for inst in instances:
            res = work(inst)
            results.append(res)
            if not args.quiet:
                print(f"  {Path(inst).name}: {_summarize(res)}", file=sys.stderr)
    else:
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
            futures = {pool.submit(work, inst): inst for inst in instances}
            for fut in concurrent.futures.as_completed(futures):
                res = fut.result()
                results.append(res)
                if not args.quiet:
                    print(f"  {Path(res.instance).name}: {_summarize(res)}",
                          file=sys.stderr)
        # Preserve discovery order in output.
        order = {inst: i for i, inst in enumerate(instances)}
        results.sort(key=lambda r: order[r.instance])

    # Emit CSV. Columns:
    #   wall_time_at_min_s:  Python-measured subprocess wall time.
    #   clingo_total_s:      clingo's Time.Total (grounding + solving + I/O).
    #   clingo_solve_s:      clingo's Time.Solve (solving only).
    #   Grounding time := clingo_total_s - clingo_solve_s.
    out = open(args.output, "w", newline="") if args.output else sys.stdout
    try:
        writer = csv.writer(out)
        writer.writerow([
            "instance", "status", "min_horizon",
            "wall_time_at_min_s", "clingo_total_s", "clingo_solve_s",
            "n_probes", "message",
        ])
        for r in results:
            writer.writerow([
                r.instance,
                r.status,
                r.min_horizon if r.min_horizon is not None else "",
                f"{r.solve_time_at_min:.4f}" if r.solve_time_at_min is not None else "",
                f"{r.clingo_total_at_min:.4f}" if r.clingo_total_at_min is not None else "",
                f"{r.clingo_solve_at_min:.4f}" if r.clingo_solve_at_min is not None else "",
                len(r.trace),
                r.message,
            ])
    finally:
        if args.output:
            out.close()

    # Exit non-zero if any instance failed to find a SAT horizon.
    any_failed = any(r.status != "FOUND" for r in results)
    return 1 if any_failed else 0


def _summarize(r: InstanceResult) -> str:
    if r.status == "FOUND":
        if r.clingo_total_at_min is not None and r.clingo_solve_at_min is not None:
            ground = r.clingo_total_at_min - r.clingo_solve_at_min
            timing = (f"total {r.clingo_total_at_min:.2f}s "
                      f"[ground {ground:.2f}s + solve {r.clingo_solve_at_min:.2f}s]")
        else:
            timing = f"wall {r.solve_time_at_min:.2f}s"
        return f"min h={r.min_horizon} ({timing}, {len(r.trace)} probes)"
    return f"{r.status}: {r.message}"


if __name__ == "__main__":
    sys.exit(main())
