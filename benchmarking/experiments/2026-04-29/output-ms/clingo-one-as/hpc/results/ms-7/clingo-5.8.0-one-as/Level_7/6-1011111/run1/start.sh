#!/bin/bash
# https://github.com/arminbiere/runlim

CAT="../../../../../../../../../programs/gcat.sh"

cd "$(dirname $0)"

runner=( "../../../../../../../../../programs/runlim" \
  --single \
  --space-limit=15000 \
  --output-file=runsolver.watcher \
  --real-time-limit=1500 \
  "../../../../../../../../../programs/clingo-5.8.0" \
   --stats 1  \
     )

input=( "../../../../../../../../../envs/modified/Test_00/Level_7/6-1011111.lp" "../../../../../../../../../envs/modified/Test_00/Level_7/cells.lp" "../../../../../../../../../experiments/exp-ms.lp" )

if [[ ! -e .finished ]]; then
  {
    if file -b --mime-type -L  "${input[@]}" | grep -qv "text/"; then
      "$CAT" "${input[@]}" | "${runner[@]}"
    else
      "${runner[@]}" "${input[@]}"
    fi
  } > runsolver.solver
fi

touch .finished
