#!/usr/bin/env bash
# nfl-boot-run.sh OUT ARM OPTS : fresh boot to an Exhibition game (default teams, CPU against CPU), ten screenshots
# from the stadium intro on, then quit and restore. BLOCKS=<file>: start with that saved block list.
E=/Volumes/Storage/UMRK/tmp/dc-core-bench/evidence/fcr-nflgrass-20261120
cd /Volumes/Storage/UMRK/tmp/dc-core-bench || exit 1
OUT="$1"; ARM="$2"; OPTS="$3"
bash $E/tools/nfl-start.sh "$OUT" "$ARM" "$OPTS" 2>&1 | grep -v pushed || exit 1
. ./lib-bench.sh
sleep 25; press --hold 150 START; sleep 6; press --hold 150 START; sleep 5
press --hold 500 --gap 0 SU; press --hold 400 --gap 0 SU+A; sleep 4
press --hold 150 START; sleep 5; press --hold 150 START; sleep 8
for n in 01 02 03 04 05 06 07 08 09 10 11 12; do sleep 6; screenshot "$OUT/g$n.png" >/dev/null 2>&1; done
grep -c . /dev/null >/dev/null
bash $E/tools/end.sh "$OUT" 2>&1 | tail -2
(cd "$OUT" && ffmpeg -loglevel error -y -i g01.png -i g03.png -i g05.png -i g07.png -i g09.png -i g11.png -filter_complex "[0]scale=480:360[a];[1]scale=480:360[b];[2]scale=480:360[c];[3]scale=480:360[d];[4]scale=480:360[e];[5]scale=480:360[f];[a][b][c]hstack=3[r1];[d][e][f]hstack=3[r2];[r1][r2]vstack" sheet.png)
grep -h 'deadcast\|blocks\|Deadcast' "$OUT/retroarch.log" | grep -iv 'perf\|profiler' | head -5
