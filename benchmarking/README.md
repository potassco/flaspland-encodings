Benchmarking seems to work on Linux but not on MacOS.

After setting up the benchmarking tool and activating the `conda` environment, follow these steps to run benchmarking:
1. Modify the runscript to consider the correct encodings and instances
2. Run the command `btool gen runscripts/runscript-<name>.xml` to generate the necessary folder structure
3. Run the command `python ./output/test-run/local/start.py`
4. To generate a results spreadsheet, run `btool eval runscripts/runscript-<name>.xml | btool conv -o results.xlsx`

---

## Runscript

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
