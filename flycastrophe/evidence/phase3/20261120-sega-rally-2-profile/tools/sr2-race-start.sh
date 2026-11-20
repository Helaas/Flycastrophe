#!/usr/bin/env bash
# sr2-race-start.sh OUT ARM : start Sega Rally 2 with the profiler and leave it running, to be stepped by hand
# (sr2-step.sh) and ended with sr2-race-end.sh, which restores the device.
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; ARM="$2"; mkdir -p "$OUT"
PROF_DIR=/userdata/fcr-prof
[ -z "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ] || { echo "a game is running: not starting" >&2; exit 1; }
echo "$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor') $(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor') $(sh_ 'cat /sys/class/devfreq/dmc/governor')" > "$OUT/governors-before.txt"
cat "$OUT/governors-before.txt"
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor; rm -rf '$PROF_DIR'; mkdir -p '$PROF_DIR'" >/dev/null
prepare_device "$ARM" >/dev/null || exit 1
pause_launcher
rom="$LEAF_SD/Roms/DC/Sega Rally 2 (USA).chd"
sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
write_ra_cfg 0
sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
EXTRA_ENV="export FLYCASTROPHE_PERF=1 DEADCAST_PROF=$PROF_DIR/sr2.prof"
start_ra "$ARM" "$rom" || { echo "start failed"; exit 1; }
echo started
