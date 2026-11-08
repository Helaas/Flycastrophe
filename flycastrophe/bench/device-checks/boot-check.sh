#!/usr/bin/env bash
# Boot check: ROM ($ROM) on each core arm, screenshots at SHOTS seconds (default 25 45 65).
set -uo pipefail
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh
OUT="$1"; shift
rom="${ROM:?ROM}"
trap 'stop_ra; resume_launcher' EXIT
for arm in "$@"; do
  prepare_device "$arm" >/dev/null
  write_ra_cfg 0
  sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
  pause_launcher
  start_ra "$arm" "$rom" || { echo "$arm: start failed"; sh_ "tail -20 $DEV_DIR/retroarch.log"; continue; }
  t0=$(date +%s)
  for at in ${SHOTS:-25 45 65}; do
    while [ $(( $(date +%s) - t0 )) -lt $at ]; do sleep 1; done
    sh_ "pidof retroarch" >/dev/null || { echo "$arm: exited before ${at}s"; break; }
    screenshot "$OUT/$arm-$TAGNAME-${at}s.png" >/dev/null 2>&1 && echo "$arm: shot ${at}s"
  done
  sh_ "grep -iE 'naomi ?2|error|exception|failed|Mali|GL_|renderer' '$DEV_DIR/retroarch.log' | grep -viE 'GET_VARIABLE|haptic|rumble|gamemode' | head -8"
  adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$arm-$TAGNAME-retroarch.log"
  stop_ra
done
