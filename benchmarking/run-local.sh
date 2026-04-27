#!/bin/bash

btool init

# bash ./build/build-runlim.sh
# bash ./build/build-clasp.sh

ln -s $(which clingo) programs/clingo-5.8.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "${SCRIPT_DIR}/zesty/runlim" programs/runlim
ln -sf "${SCRIPT_DIR}/zesty/clasp-3.4.0" programs/clasp-3.4.0

cp "zesty/runscript-path2drive-local.xml" runscripts/

btool gen ./runscripts/runscript-path2drive-local.xml

python ./output-p2d/clasp-seq/local/start.py
btool eval ./runscripts/runscript-path2drive-local.xml | btool conv -m all -o results-local.xlsx
echo "Complete."
