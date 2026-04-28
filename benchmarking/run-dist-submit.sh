# submit-dist.sh
#!/bin/bash
set -euo pipefail

btool init
ln -sf "$(which clingo)" programs/clingo-5.8.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "${SCRIPT_DIR}/zesty/runlim" programs/runlim
ln -sf "${SCRIPT_DIR}/zesty/clasp-3.4.0" programs/clasp-3.4.0
cp "zesty/runscript-$1-dist.xml" runscripts/
cp "zesty/clasp.py" resultparsers/

btool gen ./runscripts/runscript-$1-dist.xml
bash ./output-$1/clingo-one-as/hpc/start.sh

echo "Jobs submitted. Monitor with:"
echo "  squeue -u \$USER"
echo "When all jobs finish, run: bash run-dist-collect.sh"
