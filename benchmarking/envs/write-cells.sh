#!/bin/bash
# Run from: ~/git/flaspland-encodings/benchmarking/envs
set -euo pipefail

SRC_ROOT="."
DST_ROOT="./modified"

for test_dir in "$SRC_ROOT"/Test_*; do
    test_name=$(basename "$test_dir")

    # Skip Test_00 (already done manually)
    if [[ "$test_name" == "Test_00" ]]; then
        echo "Skipping $test_name (already processed manually)"
        continue
    fi

    for level_file in "$test_dir"/Level_*.lp; do
        [[ -f "$level_file" ]] || continue

        level_name=$(basename "$level_file" .lp)   # e.g. Level_3
        dst_dir="$DST_ROOT/$test_name/$level_name"
        dst_file="$dst_dir/cells.lp"

        mkdir -p "$dst_dir"
        grep '^cell(' "$level_file" > "$dst_file" || true

        echo "$level_file -> $dst_file ($(wc -l < "$dst_file") facts)"
    done
done
