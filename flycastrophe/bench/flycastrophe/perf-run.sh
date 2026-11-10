#!/usr/bin/env bash
# Runs with the core's own measurements: each run plays a game for SECS seconds with FLYCASTROPHE_PERF=1
# and the run's own environment, then QUIT; RetroArch's log (the perf lines, and the frame hashes with
# FLYCASTROPHE_GLHASH=1) is pulled to OUT/<game>-<label>-r<round>.log. Uncapped unless CAPPED=1; the runs
# of a game rotate each round; game governors, the SoC cooled below COOL_MC between runs.
#   OUT=<dir> [SECS=30] [ROUNDS=1] [CAPPED=1] [SHOT=1] [GAMES="crazy-taxi sa2"] [DISCS="name|rom on the device|state on the host;..."]
#   [CORE_OPTIONS=<file>: every run's core options, in place of the bench's or the arm's]
#       perf-run.sh "label|arm|ENV=1 OTHER=2" ...
# GAMES are the bench's games from their upstream-<game>.state. DISCS adds others: with a state, from it;
# without, booted from the BIOS. Summaries: perfsum.py (speed, frame rate) and hashcmp.py (same picture).
set -uo pipefail
BENCH_HOST="${BENCH_HOST:-$(cd "$(dirname "$0")/.." && pwd)}"
. "$BENCH_HOST/lib-bench.sh"
OUT="${OUT:?OUT}"; mkdir -p "$OUT"; SECS="${SECS:-30}"; ROUNDS="${ROUNDS:-1}"
if [ -n "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ]; then
  echo "a game or emulator is running on the device: not starting" >&2; exit 1
fi
games=()
for g in ${GAMES-crazy-taxi sa2}; do games+=("$g|$(resolve_rom "$g")|$BENCH_HOST/states/upstream-$g.state"); done
if [ -n "${DISCS:-}" ]; then IFS=';' read -r -a extra <<<"$DISCS"; games+=("${extra[@]}"); fi
O1="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"; O2="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"; O3="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
restore() { stop_ra; resume_launcher; sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$O1' > \$c/cpufreq/scaling_governor; done; echo '$O2' > /sys/class/devfreq/fde60000.gpu/governor; echo '$O3' > /sys/class/devfreq/dmc/governor; true" >/dev/null; }
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor" >/dev/null
pause_launcher
runs=("$@"); n=${#runs[@]}
for r in $(seq 1 "$ROUNDS"); do
  for entry in "${games[@]}"; do
    IFS='|' read -r game rom state <<<"$entry"
    [ -n "$rom" ] || { echo "$game: no ROM on the device"; continue; }
    base="$(state_basename "$rom")"
    for i in $(seq 0 $((n - 1))); do
      IFS='|' read -r label arm env <<<"${runs[$(( (i + r - 1) % n ))]}"
      for _ in $(seq 1 24); do t="$(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')"; [ "${t:-0}" -le "${COOL_MC:-58000}" ] && break; sleep 5; done
      prepare_device "$arm" >/dev/null </dev/null || { echo "$label: prepare failed"; continue; }
      [ -n "${CORE_OPTIONS:-}" ] && adb_ push "$CORE_OPTIONS" "$DEV_DIR/retroarch-core-options.cfg" >/dev/null </dev/null
      sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
      if [ -n "$state" ]; then
        adb_ push "$state" "$DEV_DIR/states/$base.state.auto" >/dev/null </dev/null
        write_ra_cfg 1
      else
        write_ra_cfg 0
      fi
      sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
      [ "${CAPPED:-0}" = 1 ] || sh_ "sed -i -e 's/^video_vsync = .*/video_vsync = \"false\"/' -e 's/^audio_sync = .*/audio_sync = \"false\"/' '$DEV_DIR/retroarch.cfg'" >/dev/null
      EXTRA_ENV="export FLYCASTROPHE_PERF=1 $env"
      start_ra "$arm" "$rom" </dev/null || { echo "$game $label: start failed"; continue; }
      sleep "$SECS"
      [ "${SHOT:-0}" = 1 ] && screenshot "$OUT/$game-$label-r$r.png" >/dev/null 2>&1
      ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
      sh_ "for i in \$(seq 1 100); do pidof retroarch >/dev/null || break; sleep 0.1; done; true"
      adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$game-$label-r$r.log" </dev/null
      echo "$(date +%T) $game $label r$r: $(grep -c 'Flycastrophe perf' "$OUT/$game-$label-r$r.log") perf lines, $(grep -c 'Flycastrophe glhash' "$OUT/$game-$label-r$r.log") hashed frames, $(grep -hcE 'Fatal|Verify|terminate|GL error' "$OUT/$game-$label-r$r.log") errors"
    done
  done
done
