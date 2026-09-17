"""
Script to split flatland base environment instances into smaller instances based on selected trains.

Usage:
    python gen.py DIR INSTANCE|all

Where:
    DIR       Directory containing the base environment instances.
    INSTANCE  Specific instance file to split, or "all" to split all instances in the directory.
"""

import clingo
import re
import sys
from pathlib import Path
from typing import Iterable, Match, Optional

TRAIN_IDS: list[int] = list(range(20))
HORIZON_PATTERN: re.Pattern[str] = re.compile(r"global\((\d+)\)")

ENCODING: str = """
2 { select_train(Z) : train(Z) }.

#show.
#show train(Z)     : select_train(Z).
#show start(Z,C,T,D)     : start(Z,C,T,D), select_train(Z).
#show end(Z,C,T)     : end(Z,C,T), select_train(Z).
#show global(G)     : G = #max{ T : end(Z,_,T), select_train(Z)}.
"""

def model_to_bits(atoms: Iterable[clingo.Symbol]) -> str:
    selected: set[int] = {
        sym.arguments[0].number
        for sym in atoms
        if sym.name == "train"
    }
    bits: str = "".join("1" if i in selected else "0" for i in TRAIN_IDS)
    return bits


def add_horizon(output_directory: Path) -> None:
    for filepath in output_directory.glob("*.lp"):
        content: str = filepath.read_text()
        if content.startswith("#const h="):
            continue
        match: Optional[Match[str]] = HORIZON_PATTERN.search(content)
        if not match:
            continue
        h: str = match.group(1)
        filepath.write_text(f"#const h={h}.\n{content}")


def instance_base_name(instance: str) -> str:
    return instance.removesuffix(".lp")


def split_instance(directory: str, instance: str) -> None:
    directory_path: Path = Path(directory)
    instance_base: str = instance_base_name(instance)
    ctl: clingo.Control = clingo.Control(["--models=0"])
    ctl.add("base", [], ENCODING)
    ctl.load(str(directory_path / f"{instance_base}.lp"))
    ctl.ground([("base", [])])

    output_directory: Path = Path(f"{directory}_split") / instance_base
    output_directory.mkdir(parents=True, exist_ok=True)

    file_count: int = 0

    def save_model(model: clingo.Model) -> None:
        nonlocal file_count
        file_count += 1
        atoms: list[clingo.Symbol] = model.symbols(shown=True)
        bits: str = model_to_bits(atoms)
        filename: Path = output_directory / f"{bits.count('1')}-{bits}.lp"
        with filename.open("w") as f:
            for sym in sorted(atoms, key=str):
                f.write(f"{sym}.\n")

    ctl.solve(on_model=save_model)
    add_horizon(output_directory)
    print(f"Generated {file_count} files in {output_directory}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("Usage: python gen.py DIR INSTANCE|all")

    directory: str
    instance: str
    directory, instance = sys.argv[1:]
    if instance in {"all", "*all*"}:
        directory_path: Path = Path(directory)
        instances: list[str] = sorted(
            instance_base_name(filepath.name)
            for filepath in directory_path.glob("*.lp")
        )
    else:
        instances = [instance]
    for current_instance in instances:
        split_instance(directory, current_instance)
