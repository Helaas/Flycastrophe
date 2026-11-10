#!/usr/bin/env bash
# Run cores from a savestate, uncapped (or CAPPED=1), with FLYCASTROPHE_PERF=1 and each run's own
# environment; pull RetroArch's log (perf and gl lines) and a screenshot.
#   OUT=<dir> [SECS=30] [GAMES="crazy-taxi sa2 nfl2k2"] [ROUNDS=1] glrun.sh "label|arm|ENV=1 ENV2=2" ...
set -uo pipefail
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh
OUT="${OUT:?OUT}"; mkdir -p "$OUT"; SECS="${SECS:-30}"; ROUNDS="${ROUNDS:-1}"
NFL_ROM="$LEAF_SD/flycastrophe-bench-tmp/NFL 2K2 (USA).chd"
NFL_STATE=/Volumes/Storage/UMRK/tmp/flycastrophe-pgo/kcw/states/nfl2k2-play.state
if [ -n "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ]; then
  echo "a game or emulator is running on the device: not starting" >&2; exit 1
fi
O1="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"; O2="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"; O3="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
restore() { stop_ra; resume_launcher; sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$O1' > \$c/cpufreq/scaling_governor; done; echo '$O2' > /sys/class/devfreq/fde60000.gpu/governor; echo '$O3' > /sys/class/devfreq/dmc/governor; true" >/dev/null; }
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor" >/dev/null
pause_launcher
runs=("$@"); n=${#runs[@]}
for r in $(seq 1 "$ROUNDS"); do
  for game in ${GAMES:-crazy-taxi sa2 nfl2k2}; do
    case "$game" in
      nfl2k2) rom="$NFL_ROM"; state="$NFL_STATE" ;;
      *) rom="$(resolve_rom "$game")"; state="$BENCH_HOST/states/upstream-$game.state" ;;
    esac
    base="$(state_basename "$rom")"
    for i in $(seq 0 $((n - 1))); do
      IFS='|' read -r label arm env <<<"${runs[$(( (i + r - 1) % n ))]}"
      # cool down below 58 C, as the bench does
      for c in $(seq 1 24); do t="$(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')"; [ "${t:-0}" -le "${COOL_MC:-58000}" ] && break; sleep 5; done
      prepare_device "$arm" >/dev/null || { echo "$label: prepare failed"; continue; }
      sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
      adb_ push "$state" "$DEV_DIR/states/$base.state.auto" >/dev/null
      write_ra_cfg 1
      sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
      [ "${CAPPED:-0}" = 1 ] || sh_ "sed -i -e 's/^video_vsync = .*/video_vsync = \"false\"/' -e 's/^audio_sync = .*/audio_sync = \"false\"/' '$DEV_DIR/retroarch.cfg'" >/dev/null
      EXTRA_ENV="export FLYCASTROPHE_PERF=1 $env"
      start_ra "$arm" "$rom" || { echo "$label $game: start failed"; continue; }
      sleep "$SECS"
      [ "${SHOT:-1}" = 1 ] && screenshot "$OUT/$game-$label-r$r.png" >/dev/null 2>&1
      ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
      sh_ "for i in \$(seq 1 100); do pidof retroarch >/dev/null || break; sleep 0.1; done; true"
      adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$game-$label-r$r.log"
      echo "$(date +%T) $game $label r$r: $(grep -c 'Flycastrophe perf' "$OUT/$game-$label-r$r.log") perf lines; $(grep -hcE 'Fatal|Verify|terminate|GL error' "$OUT/$game-$label-r$r.log") errors; temp $(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')"
    done
  done
done
