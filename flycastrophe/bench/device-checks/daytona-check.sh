#!/usr/bin/env bash
# Daytona: A pressed every 1.5 s from boot through the menus into a race; shots at SHOTS seconds.
set -uo pipefail
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh
OUT="$1"; shift
rom="${ROM:?ROM}"
trap 'drive_stop; stop_ra; resume_launcher' EXIT
for arm in "$@"; do
  prepare_device "$arm" >/dev/null
  write_ra_cfg 0
  sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
  pause_launcher
  start_ra "$arm" "$rom" || { echo "$arm: start failed"; continue; }
  drive_start "$DRIVE_FILE"
  t0=$(date +%s)
  for at in ${SHOTS}; do
    while [ $(( $(date +%s) - t0 )) -lt $at ]; do sleep 1; done
    sh_ "pidof retroarch" >/dev/null || { echo "$arm: exited before ${at}s"; break; }
    screenshot "$OUT/$arm-${at}s.png" >/dev/null 2>&1 && echo "$arm: shot ${at}s"
  done
  drive_stop
  adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$arm-retroarch.log"
  stop_ra
done
