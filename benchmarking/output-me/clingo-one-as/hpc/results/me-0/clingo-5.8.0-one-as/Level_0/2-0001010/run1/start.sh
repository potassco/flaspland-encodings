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

input=( "../../../../../../../../../envs/modified/Test_00/Level_0/2-0001010.lp" "../../../../../../../../../envs/modified/Test_00/Level_0/cells.lp" "../../../../../../../../../experiments/exp-me.lp" )

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
