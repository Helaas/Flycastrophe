#!/usr/bin/env bash
set -uo pipefail
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh
OUT=/Volumes/Storage/UMRK/tmp/flycastrophe-pgo/rel030/boot; mkdir -p "$OUT"
ARM=fcr-rel030
if [ -n "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ]; then echo "game running: stop" >&2; exit 1; fi
G=("$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')" "$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')" "$(sh_ 'cat /sys/class/devfreq/dmc/governor')")
restore() { stop_ra; resume_launcher
  sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '${G[0]}' > \$c/cpufreq/scaling_governor; done; echo '${G[1]}' > /sys/class/devfreq/fde60000.gpu/governor; echo '${G[2]}' > /sys/class/devfreq/dmc/governor; true" >/dev/null; }
trap restore EXIT
prepare_device "$ARM" >/dev/null || exit 1
pause_launcher
write_ra_cfg 0
start_ra "$ARM" "$LEAF_SD/Roms/DC/Power Stone (USA).chd" || { echo start failed; }
sleep 10; screenshot "$OUT/10s.png" >/dev/null 2>&1
sleep 20; screenshot "$OUT/30s.png" >/dev/null 2>&1
adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/retroarch.log"
echo "core sha $CORE_SHA"; grep -E "Game ID|cache reset|Loading|error|crash" "$OUT/retroarch.log" | head
