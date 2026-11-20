#!/usr/bin/env bash
# nfl-state-run.sh OUT ARM OPTS STATE : load the state, then A pressed over and over (coin toss, skips), a screenshot
# after each press, 16 in all; quit and restore.
E=/Volumes/Storage/UMRK/tmp/dc-core-bench/evidence/fcr-nflgrass-20261120
cd /Volumes/Storage/UMRK/tmp/dc-core-bench || exit 1
OUT="$1"; ARM="$2"; OPTS="$3"
STATE="$4" bash $E/tools/nfl-start.sh "$OUT" "$ARM" "$OPTS" 2>&1 | grep -v pushed || exit 1
. ./lib-bench.sh
sleep 7
for n in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16; do
  press --hold 120 --gap 0 A; sleep 0.6
  screenshot "$OUT/s$n.png" >/dev/null 2>&1
done
bash $E/tools/end.sh "$OUT" 2>&1 | tail -1
(cd "$OUT" && ffmpeg -loglevel error -y -pattern_type glob -i "s*.png" -vf "scale=320:240,tile=8x2" -frames:v 1 sheet.png)
