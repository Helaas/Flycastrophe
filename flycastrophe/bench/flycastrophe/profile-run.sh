#!/usr/bin/env bash
# Profile Flycastrophe on the bench's still scenes: ARM's core from its upstream-<game>.state, uncapped
# (vsync and audio sync off), FLYCASTROPHE_PERF=1 and DEADCAST_PROF on, SECS seconds, then QUIT so the
# core unloads and writes the samples; pulls the dump and RetroArch's log to $OUT.
#   ARM=fcr-<name> OUT=<dir> [GAMES="crazy-taxi sa2"] [SECS=35] profile-run.sh
set -uo pipefail
BENCH_HOST="${BENCH_HOST:-$(cd "$(dirname "$0")/.." && pwd)}"
. "$BENCH_HOST/lib-bench.sh"
ARM="${ARM:?ARM}"; OUT="${OUT:?OUT}"; mkdir -p "$OUT"
SECS="${SECS:-35}"
PROF_DIR=/userdata/fcr-prof
if [ -n "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ]; then
  echo "a game or emulator is running on the device: not starting" >&2; exit 1
fi
ORIG_GOV_CPU="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"
ORIG_GOV_GPU="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"
ORIG_GOV_DMC="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
restore() {
  stop_ra; resume_launcher
  sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$ORIG_GOV_CPU' > \$c/cpufreq/scaling_governor; done; echo '$ORIG_GOV_GPU' > /sys/class/devfreq/fde60000.gpu/governor; echo '$ORIG_GOV_DMC' > /sys/class/devfreq/dmc/governor; rm -rf '$PROF_DIR'; true" >/dev/null
}
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor; rm -rf '$PROF_DIR'; mkdir -p '$PROF_DIR'" >/dev/null
prepare_device "$ARM" >/dev/null || exit 1
pause_launcher
for game in ${GAMES:-crazy-taxi sa2}; do
  rom="$(resolve_rom "$game")"; base="$(state_basename "$rom")"
  echo "== $game $(date +%T) $rom"
  sh_ "rm -f '$DEV_DIR/states/'*; true" >/dev/null
  adb_ push "$BENCH_HOST/states/upstream-$game.state" "$DEV_DIR/states/$base.state.auto" >/dev/null
  write_ra_cfg 1
  sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'; sed -i -e 's/^video_vsync = .*/video_vsync = \"false\"/' -e 's/^audio_sync = .*/audio_sync = \"false\"/' '$DEV_DIR/retroarch.cfg'" >/dev/null
  EXTRA_ENV="export FLYCASTROPHE_PERF=1 DEADCAST_PROF=$PROF_DIR/$game.prof"
  start_ra "$ARM" "$rom" || { echo "$game: start failed"; continue; }
  sleep "$SECS"
  screenshot "$OUT/$game-end.png" >/dev/null 2>&1
  ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
  sh_ "for i in \$(seq 1 300); do pidof retroarch >/dev/null || break; sleep 0.1; done; pidof retroarch >/dev/null && echo STILL-RUNNING; true"
  adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$game-retroarch.log"
  adb_ pull "$PROF_DIR/$game.prof" "$OUT/$game.prof" >/dev/null || echo "$game: no profile written"
  grep -h 'Deadcast profiler' "$OUT/$game-retroarch.log" | tail -1
done
echo "done $(date +%T)"
