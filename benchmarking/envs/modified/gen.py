import clingo
import os

DIR = "Test_01/"
INSTANCE = "Level_0"
TRAIN_IDS = list(range(7))

def model_to_bits(atoms):
    selected = {
        sym.arguments[0].number
        for sym in atoms
        if sym.name == "train"
    }
    return "".join("1" if i in selected else "0" for i in TRAIN_IDS)

ctl = clingo.Control(["--models=0"])
ctl.load("train-selection.lp")
ctl.load(f"../{DIR}/{INSTANCE}.lp")
ctl.ground([("base", [])])

os.makedirs(f"{DIR}/{INSTANCE}", exist_ok=True)

def on_model(model):
    atoms = model.symbols(shown=True)
    bits = model_to_bits(atoms)
    filename = f"{INSTANCE}/{bits.count('1')}-{bits}.lp"
    with open(filename, "w") as f:
        for sym in sorted(atoms, key=str):
            f.write(f"{sym}.\n")

ctl.solve(on_model=on_model)