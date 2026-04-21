#!/bin/bash
btool init
git clone https://github.com/arminbiere/runlim
cd runlim/
./configure.sh && make
cp runlim ../programs/runlim
cd ..
ln -s $(which clingo) programs/clingo-5.8.0
cp zesty/runscript-path2drive-dist.xml runscripts/
btool gen ./runscripts/runscript-path2drive-dist.xml
bash ./output/clasp-as-one/hpc/start.sh
btool eval ./runscripts/runscript-path2drive-dist.xml | btool conv -m all -o results-dist.xlsx
echo "Complete."
