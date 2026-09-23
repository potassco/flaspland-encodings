# Working with benchmark environments

## `split.py`

For a given base environment, `split.py` will produce additional benchmark instances with varying numbers of trains. Users provide:
* a base environment (as an .`lp` file)
* a range for the number of trains to be selected
* the size of each class
* a random seed

See the example command:
```
$ python3 split.py Test_03/Level_3.lp --min=2 --max=10 --n=5 --seed=123
```

Here, `Test_03/Level_3.lp` serves as the base environment—every test instance will contain the same track layout. The only thing that changes is which trains are kept and which are discarded. Then, `--min=2 --max=10` specify the range of trains to be selected, resulting in different classes—instances with only 2 trains selected, with only 3 trains selected, with only 4 trains selected, …, with 10 trains selected. The class size of `--n=5` means that of all possible instances generated for each class, 5 of them will be kept, if possible. The random seed `--seed=123` is optional and allows for reproducibility.

A subdirectory based on the given input is created in the current directory which houses all of the newly-generated instances.

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