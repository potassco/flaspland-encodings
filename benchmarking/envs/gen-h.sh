#!/bin/bash
#
# gen-h.sh
#
# Traverses one or more Test_NN folders (each containing Level_0.lp .. Level_9.lp),
# extracts the value G from each file's global(G) fact, and writes out
# <add file="..." cmdline="--const h=G"/> lines ready to paste into a btool XML runscript.
#
# Usage (run from within the envs/ directory):
#   bash gen-h.sh Test_01 Test_02 Test_03
#
# Output:
#   One text file per folder, e.g. Test_01_add-lines.txt, written into envs/.

set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "Usage: bash gen-h.sh <folder1> [folder2] [folder3] ..."
    exit 1
fi

for folder in "$@"; do
    if [ ! -d "$folder" ]; then
        echo "Warning: '$folder' is not a directory, skipping." >&2
        continue
    fi

    outfile="${folder}_add-lines.txt"
    : > "$outfile"  # truncate/create empty file

    # Sort by the numeric index in Level_N.lp so output is Level_0, Level_1, ... Level_9
    # rather than lexicographic (Level_0, Level_1, Level_10, ...).
    shopt -s nullglob
    files=("$folder"/Level_*.lp)
    shopt -u nullglob

    if [ "${#files[@]}" -eq 0 ]; then
        echo "Warning: no Level_*.lp files found in '$folder', skipping." >&2
        continue
    fi

    IFS=$'\n' sorted_files=($(printf '%s\n' "${files[@]}" | sort -t_ -k2 -n))
    unset IFS

    for filepath in "${sorted_files[@]}"; do
        fname=$(basename "$filepath")

        # Extract G from a fact like: global(300).
        g=$(grep -oP 'global\(\K[0-9]+(?=\)\s*\.)' "$filepath" | head -n1 || true)

        if [ -z "$g" ]; then
            echo "Warning: no global(G) fact found in '$filepath', skipping this file." >&2
            continue
        fi

        echo "<add file=\"${fname}\" cmdline=\"--const h=${g}\"/>" >> "$outfile"
    done

    echo "Wrote $(wc -l < "$outfile") line(s) to $outfile"
done
