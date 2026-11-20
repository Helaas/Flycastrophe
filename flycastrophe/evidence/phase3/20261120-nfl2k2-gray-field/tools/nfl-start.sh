#!/usr/bin/env bash
# nfl-start.sh OUT ARM OPTS : boot NFL 2K2 (no state) with the given core and options and leave it running, to be
# stepped by hand (step.sh) and ended with end.sh, which restores the device.
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; ARM="$2"; OPTS="$3"; mkdir -p "$OUT"
[ -z "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ] || { echo "a game is running: not starting" >&2; exit 1; }
echo "$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor') $(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor') $(sh_ 'cat /sys/class/devfreq/dmc/governor')" > "$OUT/governors-before.txt"
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor" >/dev/null
prepare_device "$ARM" >/dev/null || exit 1
pause_launcher
rom="$LEAF_SD/Roms/DC/NFL 2K2 (USA).chd"
adb_ push "$OPTS" "$DEV_DIR/retroarch-core-options.cfg" >/dev/null
sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
[ -n "${BLOCKS:-}" ] && adb_ push "$BLOCKS" "$DEV_DIR/saves/NFL 2K2 (USA).blocks" >/dev/null
if [ -n "${STATE:-}" ]; then adb_ push "$STATE" "$DEV_DIR/states/NFL 2K2 (USA).state.auto" >/dev/null; write_ra_cfg 1; else write_ra_cfg 0; fi
[ -n "${CFG_APPEND:-}" ] && sh_ "printf '%s\n' '$CFG_APPEND' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
EXTRA_ENV="export FLYCASTROPHE_PERF=1 ${MORE_ENV:-}"
start_ra "$ARM" "$rom" || { echo "start failed"; exit 1; }
echo started
