# Sample command

```
python3 min-horizon.py ../exp-path2drive.lp --instances Test_01 --guess 60 --timeout 100 --h-min 20 --h-max 150 --output horizons/results_01.csv
```

---

Contents of experiment `exp-path2drive.lp` for reference:

```
#include "encodings/path2drive/pathfinding-subnodes.lp".
#include "encodings/path2drive/show-path.lp".
```

# Instance splitting

Flatland base environment instances can be split into smaller instances based on a
selection of trains using the `split.py` script.

```
python split.py DIR INSTANCE|all
```

Where `DIR` is the directory containing the base environment instances and `INSTANCE` the
instance file to split, or "all" to split all instances in the directory.

> **__NOTE:__** clingo Python API needs to be installed

Example call:

```
python split.py Test_00 Level_1
```
