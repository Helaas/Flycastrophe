#!/usr/bin/env bash
# nfl-skip-run.sh OUT ARM OPTS : fresh boot, Exhibition, then A pressed over and over to skip every cutscene, with a
# screenshot after each press (about one every 2 s), 18 in all; quit and restore.
E=/Volumes/Storage/UMRK/tmp/dc-core-bench/evidence/fcr-nflgrass-20261120
cd /Volumes/Storage/UMRK/tmp/dc-core-bench || exit 1
OUT="$1"; ARM="$2"; OPTS="$3"
bash $E/tools/nfl-start.sh "$OUT" "$ARM" "$OPTS" 2>&1 | grep -v pushed || exit 1
. ./lib-bench.sh
sleep "${BOOT_WAIT:-25}"; press --hold 150 START; sleep 6; press --hold 150 START; sleep 5
press --hold 500 --gap 0 SU; press --hold 400 --gap 0 SU+A; sleep 4
press --hold 150 START; sleep 5; press --hold 150 START; sleep "${LOAD_WAIT:-2}"
for n in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18; do
  press --hold 120 --gap 0 "${SKIP_KEY:-A}"; sleep 0.6
  screenshot "$OUT/k$n.png" >/dev/null 2>&1
done
bash $E/tools/end.sh "$OUT" 2>&1 | tail -1
(cd "$OUT" && ffmpeg -loglevel error -y -pattern_type glob -i "k*.png" -vf "scale=320:240,tile=6x3" -frames:v 1 sheet.png)
