#!/usr/bin/env bash
#
# add_horizon.sh
#
# For every .lp file in the given directory, find the largest T among all
# facts of the form  end(Z,(Y,X),T).  and prepend the line
#
#     #const h=T.
#
# to the top of that file. If a "#const h=..." line already exists, it is
# replaced rather than duplicated, so the script is safe to re-run.
#
# Example calls:
#   ./add_horizon.sh ../../benchmarks/environments/Test_00
#   for d in ../../benchmarks/environments/Test_0*; do ./add_horizon.sh "$d"; done
#
# Notes:
#   - Only files directly inside the directory are processed (not subdirs).
#   - Text after '%' on a line is ignored, so commented-out end/3 facts
#     do not count toward the maximum.
#   - Files with no end/3 facts are left untouched and reported.
#   - Files are modified in place; commit or back up first.

set -u

dir="${1:?Usage: $0 <directory-with-.lp-files>}"

if [ ! -d "$dir" ]; then
    echo "Error: '$dir' is not a directory" >&2
    exit 1
fi

shopt -s nullglob
files=("$dir"/*.lp)

if [ ${#files[@]} -eq 0 ]; then
    echo "No .lp files found in '$dir'" >&2
    exit 1
fi

updated=0
skipped=0

for f in "${files[@]}"; do
    # 1. strip comments
    # 2. pull out every end(Z,(Y,X),T) occurrence
    # 3. keep only T, sort numerically, take the largest
    max_t=$(sed 's/%.*//' "$f" \
        | grep -oE 'end\([^()]*\([^()]*\)[[:space:]]*,[[:space:]]*[0-9]+[[:space:]]*\)' \
        | sed -E 's/.*,[[:space:]]*([0-9]+)[[:space:]]*\)$/\1/' \
        | sort -n \
        | tail -1)

    if [ -z "$max_t" ]; then
        echo "SKIP   $f (no end/3 facts found)"
        skipped=$((skipped + 1))
        continue
    fi

    tmp=$(mktemp)
    {
        echo "#const h=${max_t}."
        # drop any existing '#const h=...' line so re-runs don't stack them
        grep -vE '^[[:space:]]*#const[[:space:]]+h[[:space:]]*=' "$f"
    } > "$tmp"

    # write back via cat to preserve the original file's permissions
    cat "$tmp" > "$f"
    rm -f "$tmp"

    echo "OK     $f -> #const h=${max_t}."
    updated=$((updated + 1))
done

echo "Done: ${updated} updated, ${skipped} skipped."
