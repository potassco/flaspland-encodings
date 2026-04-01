# Benchmarking flaspland environments

## Install the `btool`

Follow the instructions for setting up the [benchmarking tool](https://github.com/potassco/benchmark-tool/tree/master).

```
git clone https://github.com/potassco/benchmark-tool
cd benchmark-tool
conda create -n <env-name> python=3.10
conda activate <env-name>
pip install .
```

Then run the following command:
```
btool init
```

## Prepare the instance

Follow these steps to run the benchmarks:
1. Modify the runscript to consider the correct encodings and instances (see below)
2. Run the command `btool gen runscripts/runscript-<name>.xml` to generate the necessary folder structure
3. Run the command `python ./output/test-run/local/start.py`
4. To generate a results spreadsheet, run `btool eval runscripts/runscript-<name>.xml | btool conv -o results.xlsx`

---

## Modify the runscript

```
<system name="clingo" version="latest" measures="clasp" config="seq-generic">       
    <setting name="base" cmdline="--stats">
        <encoding file="../move2drive/move-subnodes-two.lp"/>
    </setting>
</system>
```

The `<encoding file=""/>` can be edited to consider different encodings.
Furthermore, additional lines can be added to consider additional encodings.

```
<benchmark name="flatland-instances">
    <folder path="toy-env"/>
</benchmark>
```

The `<folder path=""/>` line can be edited to consider different instances.
The benchmarking tool considers all instance files in the folder.
