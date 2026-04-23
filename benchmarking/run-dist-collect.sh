# collect-dist.sh
#!/bin/bash
set -euo pipefail

# Fail if jobs are still running
if squeue -u "$USER" -h | grep -q .; then
    echo "Error: you still have jobs in the queue. Wait for them to finish."
    squeue -u "$USER"
    exit 1
fi

btool eval ./runscripts/runscript-path2drive-dist.xml | \
    btool conv -m all -o results-dist.xlsx

echo "Results saved to results-dist.xlsx"
