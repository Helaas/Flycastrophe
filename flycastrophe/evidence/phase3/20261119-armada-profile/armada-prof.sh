#!/usr/bin/env bash
# armada-prof.sh OUT ARM SECS : Armada from armada-base.state with RT held (fly), capped as played (UNCAPPED=1: not),
# FLYCASTROPHE_PERF=1 and DEADCAST_PROF on; QUIT so the core writes the samples; pulls the dump and the log.
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; ARM="$2"; SECS="${3:-60}"; mkdir -p "$OUT"
PROF_DIR=/userdata/fcr-prof
[ -z "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ] || { echo "a game is running: not starting" >&2; exit 1; }
O1="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"; O2="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"; O3="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
restore() { drive_stop; stop_ra; resume_launcher; sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$O1' > \$c/cpufreq/scaling_governor; done; echo '$O2' > /sys/class/devfreq/fde60000.gpu/governor; echo '$O3' > /sys/class/devfreq/dmc/governor; rm -rf '$PROF_DIR'; true" >/dev/null; }
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor; rm -rf '$PROF_DIR'; mkdir -p '$PROF_DIR'" >/dev/null
prepare_device "$ARM" >/dev/null || exit 1
pause_launcher
rom="$LEAF_SD/Roms/DC/Armada (USA).chd"; base="$(state_basename "$rom")"
sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
adb_ push "$BENCH_HOST/states/armada-base.state" "$DEV_DIR/states/$base.state.auto" >/dev/null
write_ra_cfg 1
sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
[ "${UNCAPPED:-0}" = 1 ] && sh_ "sed -i -e 's/^video_vsync = .*/video_vsync = \"false\"/' -e 's/^audio_sync = .*/audio_sync = \"false\"/' '$DEV_DIR/retroarch.cfg'" >/dev/null
EXTRA_ENV="export FLYCASTROPHE_PERF=1 DEADCAST_PROF=$PROF_DIR/armada.prof"
start_ra "$ARM" "$rom" || { echo "start failed"; exit 1; }
sleep 4
drive_start "$BENCH_HOST/evidence/fcr-render-20261119/tools/drive-armada-rt.txt"
for t in 20 40; do sleep 20; screenshot "$OUT/armada-${t}s.png" >/dev/null 2>&1; done
sleep $((SECS - 44))
screenshot "$OUT/armada-end.png" >/dev/null 2>&1
drive_stop
ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
sh_ "for i in \$(seq 1 300); do pidof retroarch >/dev/null || break; sleep 0.1; done; true"
adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/armada-retroarch.log"
adb_ pull "$PROF_DIR/armada.prof" "$OUT/armada.prof" >/dev/null || echo "no profile written"
grep -h 'Deadcast profiler' "$OUT/armada-retroarch.log" | tail -2
