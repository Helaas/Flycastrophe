#!/usr/bin/env bash
# pixdump.sh OUT NAME ROM STATE SECS HASH "label|arm|opts" ... : one frame (by input hash) dumped from each arm's run,
# threaded rendering off as in fcheck.sh; pulls OUT/NAME-<label>.raw
set -uo pipefail
B=/Volumes/Storage/UMRK/tmp/dc-core-bench; . $B/lib-bench.sh
OUT="$1"; NAME="$2"; ROM="$3"; STATE="$4"; SECS="$5"; HASH="$6"; shift 6; mkdir -p "$OUT"
for a in "$@"; do
  IFS='|' read -r label arm opts <<<"$a"
  sh_ "rm -f $DEV_DIR/dump.raw" >/dev/null
  OUT="$OUT/runs" SECS="$SECS" GAMES="" DISCS="$NAME|$ROM|$STATE" CORE_OPTIONS="$opts" $B/flycastrophe/perf-run.sh \
    "$label|$arm|FLYCASTROPHE_GLHASH=1 FLYCASTROPHE_GLDUMP=$HASH:$DEV_DIR/dump.raw" </dev/null 2>&1 | grep -E 'perf lines|failed'
  adb_ pull $DEV_DIR/dump.raw "$OUT/$NAME-$label.raw" >/dev/null 2>&1 || echo "$NAME $label: no dump"
  sh_ "rm -f $DEV_DIR/dump.raw" >/dev/null
done
