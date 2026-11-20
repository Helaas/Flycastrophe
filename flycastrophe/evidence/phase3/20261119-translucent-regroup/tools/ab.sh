#!/usr/bin/env bash
# ab.sh OUT "label|arm|env" ... : two rounds of each scene through perf-run.sh, the arms in the given order
# in round 1 and reversed in round 2. SCENES: ct (Crazy Taxi still, uncapped), ce (City Escape from
# sa2-hero-intro.state, capped, 100 s), sa2 (SA2 still, uncapped), ceu (the same uncapped), nfl (NFL 2K2 play, uncapped, 30 s).
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
OUT="$1"; shift; mkdir -p "$OUT"
fwd=("$@"); rev=(); for ((i=${#fwd[@]}-1;i>=0;i--)); do rev+=("${fwd[$i]}"); done
SA2='/mnt/sdcard/Roms/DC/Sonic Adventure 2 (Europe) (En,Ja,Fr,De,Es).chd'
NFL='/mnt/sdcard/Roms/DC/NFL 2K2 (USA).chd'
for r in 1 2; do
  if [ $r = 1 ]; then arms=("${fwd[@]}"); else arms=("${rev[@]}"); fi
  for s in ${SCENES:-ct ce ceu nfl}; do
    for a in "${arms[@]}"; do
      IFS='|' read -r label arm env <<<"$a"
      case $s in
        ct)  o=(SECS=30 GAMES=crazy-taxi DISCS=) ;;
        sa2) o=(SECS=30 GAMES=sa2 DISCS=) ;;
        ce)  o=(SECS=100 CAPPED=1 GAMES= "DISCS=ce|$SA2|$BENCH_HOST/states/sa2-hero-intro.state") ;;
        ceu) o=(SECS=80 GAMES= "DISCS=ceu|$SA2|$BENCH_HOST/states/sa2-hero-intro.state") ;;
        nfl) o=(SECS=30 GAMES= "DISCS=nfl|$NFL|/Volumes/Storage/UMRK/tmp/flycastrophe-pgo/kcw/states/nfl2k2-play.state") ;;
      esac
      d="$OUT/r$r"; mkdir -p "$d"
      env OUT="$d" "${o[@]}" "$BENCH_HOST/flycastrophe/perf-run.sh" "$label|$arm|$env" </dev/null 2>&1 | grep -E 'perf lines|failed|running'
    done
  done
done
