#!/usr/bin/env bash
set -uo pipefail

if [[ $# -eq 1 ]]; then
  set -- "${ENC:-analysis.lp}" "$1"
fi

ERR=$(mktemp)
OUT=$(clingo "$@" -V0 2>"$ERR")
RC=$?
case $RC in
  10|30) ;;
  *)
    printf 'clingo failed (exit %s):\n%s\n%s\n' "$RC" "$OUT" "$(cat "$ERR")" >&2
    rm -f "$ERR"
    exit 1
    ;;
esac

# atoms are on the line immediately before SATISFIABLE
ATOMS=$(grep -B1 '^SATISFIABLE' <<< "$OUT" | head -n 1)

if [[ -z "$ATOMS" || "$ATOMS" == "SATISFIABLE" ]]; then
  printf 'no atoms in clingo output:\n%s\n' "$OUT" >&2
  rm -f "$ERR"
  exit 1
fi

if [[ -s "$ERR" ]]; then
  printf 'clingo messages:\n%s\n' "$(cat "$ERR")" >&2
fi
rm -f "$ERR"

get() {
  local v
  v=$(sed -n "s/.*$1(\([0-9]\{1,\}\)).*/\1/p" <<< "$ATOMS")
  printf '%s' "${v:-0}"
}

row() { printf '%-16s %7s\n' "$1" "$(get "$2")"; }

has() { grep -q "\b$1\b" <<< "$ATOMS"; }

list_missing() {
  grep -o 'corner_missing([0-9]\{1,\})' <<< "$ATOMS" \
    | sed 's/corner_missing(\([0-9]*\))/\1/' | paste -sd', '
}

echo
row "Switches"     num_switches
echo "========================"
row "    Type 2"       num_type_02
row "    Type 4"       num_type_04
row "    Type 5"       num_type_05
row "    Type 6"       num_type_06
echo
row "Non-switches" num_non_switches
echo "========================"
row "    Type 1"       num_type_01
row "    Type 1a"      num_type_01a
row "    Type 3"       num_type_03
echo
row "Total"        num_total
echo "========================"
if has min_env_ok; then
  printf '%-16s %7s\n' "Min environment" "PASS"
else
  printf '%-16s %7s\n' "Min environment" "FAIL"
  printf '%-16s %s\n' "  missing" "$(list_missing)"
  EXIT=3
fi
echo

exit "${EXIT:-0}"
