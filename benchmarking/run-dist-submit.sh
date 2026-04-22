# submit-dist.sh
#!/bin/bash
set -euo pipefail

btool init
ln -sf "$(which clingo)" programs/clingo-5.8.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "${SCRIPT_DIR}/zesty/runlim" programs/runlim
ln -sf "${SCRIPT_DIR}/zesty/clasp-3.4.0" programs/clasp-3.4.0
cp "zesty/runscript-path2drive-dist.xml" runscripts/

btool gen ./runscripts/runscript-path2drive-dist.xml
bash ./output-p2d/clingo-one-as/hpc/start.sh

echo "Jobs submitted. Monitor with:"
echo "  squeue -u \$USER"
echo "When all jobs finish, run: bash run-dist-collect.sh"
