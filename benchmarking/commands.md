# Benchmarking

The following is the series of commands to pass into the terminal

```
btool init
```

```
git clone https://github.com/arminbiere/runlim
```

```
cd runlim/
```

```
./configure.sh && make
```

```
cp runlim ../programs/runlim
```

```
cd ..
```

```
ln -s $(which clingo) programs/clingo-5.8.0
```

```
cp zesty/runscript-path2drive.xml runscripts/
```

```
btool gen ./runscripts/runscript-path2drive.xml
```

```
python ./output-p2d/clasp-seq/local/start.py
```

```
btool eval ./runscripts/runscript-path2drive.xml | btool conv -o results.xlsx
```
