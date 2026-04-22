btool init

# bash ./build/build-runlim.sh
# bash ./build/build-clasp.sh

ln -s $(which clingo) programs/clingo-5.8.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "${SCRIPT_DIR}/zesty/runlim" programs/runlim
ln -sf "${SCRIPT_DIR}/zesty/clasp-3.4.0" programs/clasp-3.4.0

cp "zesty/runscript-path2drive-dist.xml" runscripts/

btool gen ./runscripts/runscript-path2drive-dist.xml

# python ./output-p2d/clingo-one-as/hpc/start.py
bash ./output-p2d/clingo-one-as/hpc/start.sh
btool eval ./runscripts/runscript-path2drive-dist.xml | btool conv -m all -o results-dist.xlsx
echo "Complete."
