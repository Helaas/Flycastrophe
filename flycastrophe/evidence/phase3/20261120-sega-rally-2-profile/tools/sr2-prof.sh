#!/usr/bin/env bash
# sr2-prof.sh OUT ARM SECS : Sega Rally 2 booted with no input (its 3D attract starts about 50 s in), capped as played,
# FLYCASTROPHE_PERF=1 and DEADCAST_PROF on; QUIT so the core writes the samples; pulls the dump and the log.
# Modelled on fcr-render-20261119/tools/armada-prof.sh.
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; ARM="$2"; SECS="${3:-200}"; mkdir -p "$OUT"
PROF_DIR=/userdata/fcr-prof
[ -z "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ] || { echo "a game is running: not starting" >&2; exit 1; }
O1="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"; O2="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"; O3="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
echo "governors before: $O1 $O2 $O3"
restore() { stop_ra; resume_launcher; sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$O1' > \$c/cpufreq/scaling_governor; done; echo '$O2' > /sys/class/devfreq/fde60000.gpu/governor; echo '$O3' > /sys/class/devfreq/dmc/governor; rm -rf '$PROF_DIR'; true" >/dev/null; echo "restored"; }
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor; rm -rf '$PROF_DIR'; mkdir -p '$PROF_DIR'" >/dev/null
prepare_device "$ARM" >/dev/null || exit 1
echo "core sha: $CORE_SHA"
pause_launcher
rom="$LEAF_SD/Roms/DC/Sega Rally 2 (USA).chd"
sh_ "test -f '$rom'" || { echo "rom missing: $rom"; exit 1; }
sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
write_ra_cfg 0
sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
[ "${UNCAPPED:-0}" = 1 ] && sh_ "sed -i -e 's/^video_vsync = .*/video_vsync = \"false\"/' -e 's/^audio_sync = .*/audio_sync = \"false\"/' '$DEV_DIR/retroarch.cfg'" >/dev/null
EXTRA_ENV="export FLYCASTROPHE_PERF=1 DEADCAST_PROF=$PROF_DIR/sr2.prof ${MORE_ENV:-}"
start_ra "$ARM" "$rom" || { echo "start failed"; exit 1; }
done_s=0
for t in 70 130 190; do
  [ "$t" -lt "$SECS" ] || break
  sleep $((t - done_s)); done_s=$t
  screenshot "$OUT/sr2-${t}s.png" >/dev/null 2>&1
done
sleep $((SECS - done_s))
ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
sh_ "for i in \$(seq 1 300); do pidof retroarch >/dev/null || break; sleep 0.1; done; true"
adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/sr2-retroarch.log"
adb_ pull "$PROF_DIR/sr2.prof" "$OUT/sr2.prof" >/dev/null || echo "no profile written"
grep -h 'Deadcast profiler' "$OUT/sr2-retroarch.log" | tail -2
echo "perf lines: $(grep -c 'Flycastrophe perf' "$OUT/sr2-retroarch.log")"
