#!/usr/bin/env bash
# sr2-race-end.sh OUT : quit so the profile is written, pull log and dump, restore governors and the launcher
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; PROF_DIR=/userdata/fcr-prof
drive_stop
ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
sh_ "for i in \$(seq 1 300); do pidof retroarch >/dev/null || break; sleep 0.1; done; true"
adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/sr2-retroarch.log"
adb_ pull "$PROF_DIR/sr2.prof" "$OUT/sr2.prof" >/dev/null || echo "no profile written"
read -r O1 O2 O3 < "$OUT/governors-before.txt"
stop_ra; resume_launcher
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$O1' > \$c/cpufreq/scaling_governor; done; echo '$O2' > /sys/class/devfreq/fde60000.gpu/governor; echo '$O3' > /sys/class/devfreq/dmc/governor; rm -rf '$PROF_DIR'; true" >/dev/null
echo "restored: $(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor /sys/class/devfreq/fde60000.gpu/governor /sys/class/devfreq/dmc/governor' | tr '\n' ' ') running: [$(sh_ 'pidof retroarch; true')]"
echo "perf lines: $(grep -c 'Flycastrophe perf' "$OUT/sr2-retroarch.log")"
