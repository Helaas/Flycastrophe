#!/usr/bin/env bash
# t5.sh OUT ARM "label|core-options-file" ... : as played (vsync and audio sync on), each scene once per arm in the
# given order in round 1 and reversed in round 2; FLYCASTROPHE_PERF=1 lines plus RetroArch's GET_PERF_INFO every
# 5 s (presented fps, frame time p95, dropped). SCENES: ct ce nfl armada sr2 (Sega Rally 2's attract, 30 fps).
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; ARM="$2"; shift 2; mkdir -p "$OUT"
[ -z "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ] || { echo "a game is running: not starting" >&2; exit 1; }
O1="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"; O2="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"; O3="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
restore() { drive_stop; stop_ra; resume_launcher; sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$O1' > \$c/cpufreq/scaling_governor; done; echo '$O2' > /sys/class/devfreq/fde60000.gpu/governor; echo '$O3' > /sys/class/devfreq/dmc/governor; true" >/dev/null; }
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor" >/dev/null
pause_launcher
DCR="$LEAF_SD/Roms/DC"; S=$BENCH_HOST/states
fwd=("$@"); rev=(); for ((i=${#fwd[@]}-1;i>=0;i--)); do rev+=("${fwd[$i]}"); done
for r in 1 2; do
  if [ $r = 1 ]; then arms=("${fwd[@]}"); else arms=("${rev[@]}"); fi
  for s in ${SCENES:-ct ce nfl armada sr2}; do
    drive=""
    case $s in
      ct) rom="$(resolve_rom crazy-taxi)"; state=$S/upstream-crazy-taxi.state; secs=40 ;;
      ce) rom="$DCR/Sonic Adventure 2 (Europe) (En,Ja,Fr,De,Es).chd"; state=$S/sa2-hero-intro.state; secs=95 ;;
      nfl) rom="$DCR/NFL 2K2 (USA).chd"; state=/Volumes/Storage/UMRK/tmp/flycastrophe-pgo/kcw/states/nfl2k2-play.state; secs=35 ;;
      armada) rom="$DCR/Armada (USA).chd"; state=$S/armada-base.state; secs=45; drive=$BENCH_HOST/evidence/fcr-render-20261119/tools/drive-armada-rt.txt ;;
      sr2) rom="$DCR/Sega Rally 2 (USA).chd"; state=""; secs=100 ;;
    esac
    base="$(state_basename "$rom")"
    for a in "${arms[@]}"; do
      IFS='|' read -r label opts <<<"$a"
      for _ in $(seq 1 24); do t="$(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')"; [ "${t:-0}" -le 58000 ] && break; sleep 5; done
      prepare_device "$ARM" >/dev/null </dev/null || { echo "prepare failed"; continue; }
      adb_ push "$opts" "$DEV_DIR/retroarch-core-options.cfg" >/dev/null </dev/null
      sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
      if [ -n "$state" ]; then adb_ push "$state" "$DEV_DIR/states/$base.state.auto" >/dev/null </dev/null; write_ra_cfg 1; else write_ra_cfg 0; fi
      sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
      EXTRA_ENV="export FLYCASTROPHE_PERF=1"
      f="$OUT/$s-$label-r$r"
      start_ra "$ARM" "$rom" </dev/null || { echo "$s $label: start failed"; continue; }
      [ -n "$drive" ] && { sleep 4; drive_start "$drive"; }
      : > "$f.perfinfo"
      for i in $(seq 1 $((secs / 5))); do sleep 5; ra_cmd "raw-request GET_PERF_INFO" 2>/dev/null | tr '\n' ' ' >> "$f.perfinfo"; echo >> "$f.perfinfo"; done
      [ -n "$drive" ] && drive_stop
      [ "$s" = sr2 ] && screenshot "$f.png" >/dev/null 2>&1
      ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
      sh_ "for i in \$(seq 1 100); do pidof retroarch >/dev/null || break; sleep 0.1; done; true"
      adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$f.log" </dev/null
      echo "$(date +%T) $s $label r$r: $(grep -c 'Flycastrophe perf' "$f.log") perf lines, last: $(tail -1 "$f.perfinfo" | grep -oE 'fps=[0-9.]+ frame_time_p95_ms=[0-9.]+|dropped=[0-9]+' | tr '\n' ' ')"
    done
  done
done
