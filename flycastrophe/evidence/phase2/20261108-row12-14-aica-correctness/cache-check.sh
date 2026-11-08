#!/usr/bin/env bash
# Code cache check: run GAME on ARM twice from its bench state (SECS each), stopping with SIGTERM;
# after each run, show the core's unload lines and the .blocks files; the second run should warm.
set -uo pipefail
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh
ARM="${ARM:?ARM}"; GAME="${GAME:-crazy-taxi}"; SECS="${SECS:-15}"; OUT="${1:?out dir}"
mkdir -p "$OUT"
trap 'stop_ra; resume_launcher' EXIT
rom="$(resolve_rom "$GAME")"
base="$(basename "${rom%.*}")"
state="$BENCH_HOST/states/upstream-$GAME.state"
prepare_device "$ARM" >/dev/null
write_ra_cfg 1
sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
[ -n "${CLEAR:-}" ] && sh_ "rm -f '$DEV_DIR/saves/'*.blocks; true"
pause_launcher
for run in 1 2; do
  sh_ "rm -f '$DEV_DIR/states/'*; true" >/dev/null
  adb_ push "$state" "$DEV_DIR/states/$base.state.auto" >/dev/null
  start_ra "$ARM" "$rom" || { echo "run $run: start failed"; continue; }
  sleep "$SECS"
  if [ "${STOP:-term}" = quit ]; then ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null; fi
  sh_ "[ '${STOP:-term}' = quit ] || pkill -x retroarch; for i in \$(seq 1 50); do pidof retroarch >/dev/null || break; sleep 0.1; done; pidof retroarch >/dev/null && echo STILL-RUNNING; true"
  adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/run$run.log"
  echo "== run $run"
  grep -E 'Deadcast: .*blocks|unloading|Unloading|SIGTERM|signal' "$OUT/run$run.log" | head
  sh_ "ls -la '$DEV_DIR/saves/' | grep -i blocks; true"
done
