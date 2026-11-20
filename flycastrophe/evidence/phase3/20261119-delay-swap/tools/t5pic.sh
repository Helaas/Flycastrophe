#!/usr/bin/env bash
# t5pic.sh OUT ARM "label|core-options-file" ... : the frame check's games booted from the BIOS with no input, as played
# (vsync and audio sync on, threaded rendering on), screenshots at fixed times (SHOTS, seconds), the perf line on
# (fcr-dsdiag counts screen renders the game never flipped to). ONLY="a b" for a subset.
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; ARM="$2"; shift 2; mkdir -p "$OUT"
SHOTS="${SHOTS:-6 10 14 18 24 30 38 46 55}"
[ -z "$(sh_ 'pidof retroarch drastic flycast mupen64plus PPSSPPSDL; true')" ] || { echo "a game is running: not starting" >&2; exit 1; }
O1="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"; O2="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"; O3="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
restore() { stop_ra; resume_launcher; sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$O1' > \$c/cpufreq/scaling_governor; done; echo '$O2' > /sys/class/devfreq/fde60000.gpu/governor; echo '$O3' > /sys/class/devfreq/dmc/governor; rmdir '$LEAF_SD/flycastrophe-bench-tmp' 2>/dev/null; true" >/dev/null; }
trap restore EXIT
sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor; done; echo performance > /sys/class/devfreq/fde60000.gpu/governor; echo performance > /sys/class/devfreq/dmc/governor" >/dev/null
pause_launcher
DC="/Volumes/home/Roms/Myrient/RA - Sega Dreamcast"; CARD_DC="$LEAF_SD/Roms/DC"; TMP="$LEAF_SD/flycastrophe-bench-tmp"; R="$DEV_DIR/roms"
GAMES=(
  "doa2|$CARD_DC/Dead or Alive 2 (USA).chd|" "powerstone|$CARD_DC/Power Stone (USA).chd|" "segarally2|$CARD_DC/Sega Rally 2 (USA).chd|"
  "daytona|$CARD_DC/Daytona USA 2001 (Europe) (En,Fr,De,Es).chd|" "spiderman|$CARD_DC/Spider-Man (USA).chd|"
  "ecco|$CARD_DC/Ecco the Dolphin - Defender of the Future (USA) (En,Fr,De,Es).chd|" "armada|$CARD_DC/Armada (USA).chd|"
  "sonicadventure|$CARD_DC/Sonic Adventure (USA) (En,Ja,Fr,De,Es) (Rev A).chd|" "headhunter|$CARD_DC/Headhunter (Europe) (EnFrDeEs).m3u|"
  "capsnk|$LEAF_SD/Roms/NAOMI/capsnk.zip|" "ggxx|$LEAF_SD/Roms/NAOMI/ggxx.zip|" "dolphin|$LEAF_SD/Roms/ATOMISWAVE/dolphin.zip|"
  "fotns|$LEAF_SD/Roms/ATOMISWAVE/fotns.zip|" "mslug6|$LEAF_SD/Roms/ATOMISWAVE/mslug6.zip|" "vf4|$R/vf4cart.zip|"
  "mvc2|$TMP/mvc2.chd|$DC/Marvel vs. Capcom 2 (USA).chd" "rez|$TMP/rez.chd|$DC/Rez (Europe) (En,Ja,Fr,De,Es,It).chd"
  "shenmue|$TMP/shenmue1.chd|$DC/Shenmue (Europe) (En,Fr,De,Es)/Shenmue (Europe) (En,Fr,De,Es) (Disc 1).chd"
  "skies|$TMP/skies1.chd|$DC/Skies of Arcadia (Europe) (En,Fr,De,Es)/Skies of Arcadia (Europe) (En,Fr,De,Es) (Disc 1).chd"
  "soulcalibur|$TMP/soulcalibur.chd|$DC/Soulcalibur (Europe) (En,Fr,De,Es).chd" "jetsetradio|$TMP/jetsetradio.chd|$DC/Jet Set Radio (Europe) (En,Fr,De,Es).chd"
  "virtuatennis2|$TMP/virtuatennis2.chd|$DC/Virtua Tennis 2 - Sega Professional Tennis (Europe) (En,Fr,De,Es).chd"
  "thps2|$TMP/thps2.chd|$DC/Tony Hawk's Pro Skater 2 (USA).chd" "vf3tb|$TMP/vf3tb.chd|$DC/Virtua Fighter 3tb (USA).chd" "ikaruga|$TMP/ikaruga.chd|$DC/Ikaruga (Japan).chd"
)
if [ -n "${ONLY:-}" ]; then sel=(); for g in "${GAMES[@]}"; do case " $ONLY " in *" ${g%%|*} "*) sel+=("$g") ;; esac; done; GAMES=("${sel[@]}"); fi
for entry in "${GAMES[@]}"; do
  IFS='|' read -r name rom src <<<"$entry"
  if [ -n "$src" ]; then sh_ "mkdir -p '$TMP'" >/dev/null </dev/null; adb_ push "$src" "$rom" >/dev/null </dev/null || { echo "$name: copy failed"; continue; }; fi
  for a in "$@"; do
    IFS='|' read -r label opts <<<"$a"
    for _ in $(seq 1 24); do t="$(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')"; [ "${t:-0}" -le 58000 ] && break; sleep 5; done
    prepare_device "$ARM" >/dev/null </dev/null || continue
    adb_ push "$opts" "$DEV_DIR/retroarch-core-options.cfg" >/dev/null </dev/null
    sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/saves/'*.blocks; true" >/dev/null
    write_ra_cfg 0
    sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
    EXTRA_ENV="export FLYCASTROPHE_PERF=1"
    start_ra "$ARM" "$rom" </dev/null || { echo "$name $label: start failed"; continue; }
    t0=$(date +%s)
    for at in $SHOTS; do
      while [ $(( $(date +%s) - t0 )) -lt "$at" ]; do sleep 0.5; done
      screenshot "$OUT/$name-$label-$(printf %02d "$at")s.png" >/dev/null 2>&1 </dev/null
    done
    ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
    sh_ "for i in \$(seq 1 100); do pidof retroarch >/dev/null || break; sleep 0.1; done; true"
    adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$name-$label.log" </dev/null
    n=$(grep -o 'not flipped to [0-9]*' "$OUT/$name-$label.log" | awk '{s+=$4} END {print s+0}')
    echo "$(date +%T) $name $label: screen renders not flipped to: $n, perf lines $(grep -c 'Flycastrophe perf' "$OUT/$name-$label.log")"
  done
  [ -n "$src" ] && sh_ "rm -f '$rom'" >/dev/null </dev/null
done | tee -a "$OUT/t5pic.txt"
