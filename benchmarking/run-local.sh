#!/bin/bash

btool init

# bash ./build/build-runlim.sh
# bash ./build/build-clasp.sh

ln -s $(which clingo) programs/clingo-5.8.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "${SCRIPT_DIR}"
ln -sf "${SCRIPT_DIR}/zesty/runlim" programs/runlim
ln -sf "${SCRIPT_DIR}/zesty/clasp-3.4.0" programs/clasp-3.4.0

cp "zesty/runscript-$1-local.xml" runscripts/
cp "zesty/clasp.py" resultparsers/

btool gen ./runscripts/runscript-$1-local.xml

python ./output-$1/clasp-seq/local/start.py
btool eval ./runscripts/runscript-$1-local.xml | btool conv -m all -o results-$1-local.xlsx
echo "Complete."
