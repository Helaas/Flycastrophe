#!/usr/bin/env bash
# PGO training for Flycastrophe on the MLP1: the instrumented core (arm fcr-pgogen, built with
# Flycastrophe-pak `PGO=generate core/build-core.sh`) in Leaf's RetroArch with the bench config,
# Leaf's game governors, the shipped core defaults except Auto Skip Frame off (every frame drawn).
# Upstream issue savestates play for SECS seconds each with a generic input loop; discs without a
# state boot into their attract demos for BOOT_SECS. Each run quits RetroArch through its command
# port so libgcov writes the counters (merged run over run) under GCOV_DIR; the tree is pulled to
# $OUT/gcda at the end. Crazy Taxi and SA2 (the bench games) are left out on purpose.
# Put the instrumented core at out/fcr-pgogen_libretro.so first; core-options-arm-fcr-pgogen.cfg
# holds the one option set for training (reicast_auto_skip_frame = "disabled").
#   STATES_DIR=<unpacked issue states> OUT=<dir> [ONLY="label ..."] flycastrophe/pgo-train.sh
# STATES_DIR is the downloads folder as evidence/phase3/20261108-upstream-states/unpack_inspect.py
# leaves it (<issue>-<attachment id>/extracted/<name>.raw.state); the states aren't in this
# repository (upstream-savestates.md lists where each comes from).
set -uo pipefail
BENCH_HOST="${BENCH_HOST:-$(cd "$(dirname "$0")/.." && pwd)}"
. "$BENCH_HOST/lib-bench.sh"
OUT="${OUT:?OUT}"; mkdir -p "$OUT"
ARM=fcr-pgogen
DL="${STATES_DIR:?STATES_DIR}"
DRIVE="$BENCH_HOST/drive-generic.txt"
CARD="$LEAF_SD/Roms/DC"
GCOV_DIR=/userdata/fcr-pgo/gcda
SECS="${SECS:-60}"; BOOT_SECS="${BOOT_SECS:-90}"
EXTRA_ENV="export GCOV_PREFIX=$GCOV_DIR GCOV_PREFIX_STRIP=2"

# label|disc on the card|raw state ("" = boot into the attract demo)
RUNS=(
  "spiderman-0|Spider-Man (USA).chd|$DL/2191-24507012/extracted/Spider-Man (USA).state.raw.state"
  "spiderman-1|Spider-Man (USA).chd|$DL/2191-24507012/extracted/Spider-Man (USA)_1.state.raw.state"
  "spiderman-2|Spider-Man (USA).chd|$DL/2191-24507012/extracted/Spider-Man (USA)_2.state.raw.state"
  "ecco|Ecco the Dolphin - Defender of the Future (USA) (En,Fr,De,Es).chd|$DL/1610-16739623/extracted/Ecco the Dolphin - Defender of the Future (USA) (En,Fr,De,Es).state.raw.state"
  "sonic|Sonic Adventure (USA) (En,Ja,Fr,De,Es) (Rev A).chd|$DL/1600-16664186/extracted/Sonic Adventure (USA) (En,Ja,Fr,De,Es) (Rev A).state3.raw.state"
  "doa2-boot|Dead or Alive 2 (USA).chd|"
  "powerstone-boot|Power Stone (USA).chd|"
)

if [ -n "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ]; then
  echo "a game or emulator is running on the device: not starting" >&2; exit 1
fi
ORIG_GOV_CPU="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"
ORIG_GOV_GPU="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"
ORIG_GOV_DMC="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
restore() {
  drive_stop; stop_ra; resume_launcher
  sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$ORIG_GOV_CPU' > \$c/cpufreq/scaling_governor; done; echo '$ORIG_GOV_GPU' > /sys/class/devfreq/fde60000.gpu/governor; echo '$ORIG_GOV_DMC' > /sys/class/devfreq/dmc/governor; true" >/dev/null
}
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor" >/dev/null

if [ -n "${ONLY:-}" ]; then sel=(); for r in "${RUNS[@]}"; do case " $ONLY " in *" ${r%%|*} "*) sel+=("$r") ;; esac; done; RUNS=("${sel[@]}"); fi
prepare_device "$ARM" >/dev/null || exit 1
sh_ "rm -rf '$GCOV_DIR'; mkdir -p '$GCOV_DIR'" >/dev/null
pause_launcher
{
  echo "core_sha256=$CORE_SHA"
  echo "secs=$SECS boot_secs=$BOOT_SECS"
} > "$OUT/meta.txt"

for run in "${RUNS[@]}"; do
  IFS='|' read -r label disc state <<<"$run"
  rom="$CARD/$disc"; base="${disc%.*}"
  echo "== $label $(date +%T)"
  sh_ "rm -f '$DEV_DIR/states/'*; true" >/dev/null
  if [ -n "$state" ]; then
    [ -f "$state" ] || { echo "$label: no state"; continue; }
    adb_ push "$state" "$DEV_DIR/states/$base.state.auto" >/dev/null
    write_ra_cfg 1; secs="$SECS"
  else
    write_ra_cfg 0; secs="$BOOT_SECS"
  fi
  sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
  start_ra "$ARM" "$rom" || { echo "$label: start failed"; adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$label-retroarch.log"; continue; }
  [ -n "$state" ] && drive_start "$DRIVE"
  sleep 10; screenshot "$OUT/$label-10s.png" >/dev/null 2>&1
  sleep $((secs - 10)); screenshot "$OUT/$label-end.png" >/dev/null 2>&1
  drive_stop
  ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
  sh_ "for i in \$(seq 1 200); do pidof retroarch >/dev/null || break; sleep 0.1; done; pidof retroarch >/dev/null && echo STILL-RUNNING; true"
  adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$label-retroarch.log"
  grep -hE 'Loading state|Failed to load|terminate called|Game ID' "$OUT/$label-retroarch.log" | head -3
  echo "$label: $(sh_ "ls '$GCOV_DIR' | wc -l") .gcda files so far"
done

adb_ pull "$GCOV_DIR" "$OUT/" >/dev/null
echo "pulled $(ls "$OUT/gcda" | wc -l | tr -d ' ') .gcda files ($(ls "$OUT/gcda" | grep -c '#rend#') renderer) to $OUT/gcda"
sh_ "rm -rf /userdata/fcr-pgo" >/dev/null
echo "done $(date +%T)"
