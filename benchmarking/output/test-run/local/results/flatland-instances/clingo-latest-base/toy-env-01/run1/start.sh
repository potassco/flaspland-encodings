#!/bin/bash
# https://github.com/arminbiere/runlim

CAT="../../../../../../../../programs/gcat.sh"

cd "$(dirname $0)"

runner=( "../../../../../../../../programs/runlim" \
  --single \
  --space-limit=20000 \
  --output-file=runsolver.watcher \
  --real-time-limit=600 \
  "../../../../../../../../programs/clingo-latest" \
   --stats  \
     )

input=( "../../../../../../../../toy-env/toy-env-01.lp" "../../../../../../../../../move2drive/move-subnodes-two.lp" )

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
