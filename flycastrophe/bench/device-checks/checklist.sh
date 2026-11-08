#!/usr/bin/env bash
# Play-checklist boot check on one arm: each game copied to the bench folder, booted with no input,
# screenshots at SHOTS seconds, QUIT over the command port, then the game removed again.
# usage: checklist.sh OUT ARM   (games listed below)
set -uo pipefail
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh
OUT="$1"; ARM="$2"; SHOTS="${SHOTS:-30 60 100}"
mkdir -p "$OUT"
DC="/Volumes/home/Roms/Myrient/RA - Sega Dreamcast"
NA="/Volumes/home/Roms/SEGA Arcade/naomi"
AW="/Volumes/home/Roms/SEGA Arcade/atomiswave"
BIOS="${BIOS_DIR:?BIOS_DIR: folder holding naomi.zip, awbios.zip and naomigd.zip}"
R="$DEV_DIR/roms"
trap 'stop_ra; resume_launcher' EXIT

# BIOS for the arcade games, next to the Dreamcast BIOS
adb_ push "$BIOS/naomi.zip" "$BIOS/awbios.zip" "$BIOS/naomigd.zip" "$DEV_DIR/system/dc/" >/dev/null

# name|device rom|host file to push (device name = basename of the rom unless a dir)|...
GAMES=(
  "doa2|$R/doa2.chd|$DC/Dead or Alive 2 (USA).chd"
  "mvc2|$R/mvc2.chd|$DC/Marvel vs. Capcom 2 (USA).chd"
  "powerstone|$R/powerstone.chd|$DC/Power Stone (USA).chd"
  "rez|$R/rez.chd|$DC/Rez (Europe) (En,Ja,Fr,De,Es,It).chd"
  "shenmue|$R/shenmue1.chd|$DC/Shenmue (Europe) (En,Fr,De,Es)/Shenmue (Europe) (En,Fr,De,Es) (Disc 1).chd"
  "skies|$R/skies1.chd|$DC/Skies of Arcadia (Europe) (En,Fr,De,Es)/Skies of Arcadia (Europe) (En,Fr,De,Es) (Disc 1).chd"
  "daytona|$R/daytona.chd|$DC/Daytona USA 2001 (Europe) (En,Fr,De,Es).chd"
  "capsnk|$R/capsnk.zip|$NA/capsnk.zip"
  "ggxx|$R/ggxx.zip|$NA/ggxx.zip|$NA/ggxx/gdl-0011.chd>$R/ggxx/gdl-0011.chd"
  "dolphin|$R/dolphin.zip|$AW/dolphin.zip"
  "fotns|$R/fotns.zip|$AW/fotns.zip"
  "mslug6|$R/mslug6.zip|$AW/mslug6.zip"
)
# CARD=1: games already on the device, booted in place (nothing pushed or removed)
if [ "${CARD:-0}" = 1 ]; then
  GAMES=(
    "headhunter|/mnt/sdcard/Roms/DC/Headhunter (Europe) (EnFrDeEs).m3u|"
    "segarally2|$R/Sega Rally 2 (USA).chd|"
    "vf4|$R/vf4cart.zip|"
    "capsnk|/mnt/sdcard/Roms/NAOMI/capsnk.zip|"
    "ggxx|/mnt/sdcard/Roms/NAOMI/ggxx.zip|"
    "dolphin|/mnt/sdcard/Roms/ATOMISWAVE/dolphin.zip|"
    "fotns|/mnt/sdcard/Roms/ATOMISWAVE/fotns.zip|"
    "mslug6|/mnt/sdcard/Roms/ATOMISWAVE/mslug6.zip|"
  )
fi
[ -n "${ONLY:-}" ] && { sel=(); for g in "${GAMES[@]}"; do case " $ONLY " in *" ${g%%|*} "*) sel+=("$g") ;; esac; done; GAMES=("${sel[@]}"); }

prepare_device "$ARM" >/dev/null
for entry in "${GAMES[@]}"; do
  IFS='|' read -r name rom files <<<"$entry"
  echo "== $name"
  pushed=()
  parts=()
  [ -n "$files" ] && IFS='|' read -r -a parts <<<"$files"
  for f in ${parts[@]+"${parts[@]}"}; do
    src="${f%%>*}"; dst="$rom"
    [ "$f" != "$src" ] && dst="${f#*>}"
    sh_ "mkdir -p '$(dirname "$dst")'" >/dev/null
    adb_ push "$src" "$dst" >/dev/null || { echo "$name: push failed"; continue 2; }
    pushed+=("$dst")
  done
  write_ra_cfg 0
  sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
  pause_launcher
  if start_ra "$ARM" "$rom"; then
    t0=$(date +%s); alive=1
    for at in $SHOTS; do
      while [ $(( $(date +%s) - t0 )) -lt $at ]; do sleep 1; done
      sh_ "pidof retroarch" >/dev/null || { echo "$name: exited before ${at}s"; alive=0; break; }
      screenshot "$OUT/$name-${at}s.png" >/dev/null 2>&1 && echo "$name: shot ${at}s"
    done
    if [ $alive = 1 ]; then
      ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
      sh_ "for i in \$(seq 1 50); do pidof retroarch >/dev/null || break; sleep 0.1; done; pidof retroarch >/dev/null && echo '$name: still running after QUIT'; true"
    fi
  else
    echo "$name: start failed"
  fi
  adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$name-retroarch.log"
  grep -E 'Game ID|terminate called|BIOS|Error|error loading|Failed to load content' "$OUT/$name-retroarch.log" | grep -v 'Invalid value' | head -4
  stop_ra
  for d in ${pushed[@]+"${pushed[@]}"}; do sh_ "rm -f '$d'" >/dev/null; done
  [ ${#pushed[@]} -gt 0 ] && sh_ "rmdir '$R/ggxx' 2>/dev/null; true" >/dev/null
done
