#!/usr/bin/env bash
# nfl-shots.sh OUT ARM OPTS [SECS] : NFL 2K2 from the saved play with the given core and core options file, as played
# (vsync + audio sync); screenshots every 8 s; FLYCASTROPHE_PERF on. Restores governors and the launcher.
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; ARM="$2"; OPTS="$3"; SECS="${4:-34}"; mkdir -p "$OUT"
[ -z "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ] || { echo "a game is running: not starting" >&2; exit 1; }
O1="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"; O2="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"; O3="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
restore() { stop_ra; resume_launcher; sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$O1' > \$c/cpufreq/scaling_governor; done; echo '$O2' > /sys/class/devfreq/fde60000.gpu/governor; echo '$O3' > /sys/class/devfreq/dmc/governor; true" >/dev/null; }
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor" >/dev/null
prepare_device "$ARM" >/dev/null || exit 1
pause_launcher
rom="$LEAF_SD/Roms/DC/NFL 2K2 (USA).chd"; base="$(state_basename "$rom")"
adb_ push "$OPTS" "$DEV_DIR/retroarch-core-options.cfg" >/dev/null
sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
adb_ push "${STATE:-/Volumes/Storage/UMRK/tmp/flycastrophe-pgo/kcw/states/nfl2k2-play.state}" "$DEV_DIR/states/$base.state.auto" >/dev/null
write_ra_cfg 1
sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
EXTRA_ENV="export FLYCASTROPHE_PERF=1 ${MORE_ENV:-}"
start_ra "$ARM" "$rom" || { echo "start failed"; exit 1; }
sleep "${FIRST:-24}"; t="${FIRST:-24}"
while [ "$t" -le "$SECS" ]; do sleep 1; t=$((t + 3)); screenshot "$OUT/$ARM-${t}s.png" >/dev/null 2>&1; done
ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
sh_ "for i in \$(seq 1 100); do pidof retroarch >/dev/null || break; sleep 0.1; done; true"
adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$ARM.log"
echo "$ARM: $(ls "$OUT" | grep -c "^$ARM-.*png") shots, $(grep -c 'Flycastrophe perf' "$OUT/$ARM.log") perf lines"
