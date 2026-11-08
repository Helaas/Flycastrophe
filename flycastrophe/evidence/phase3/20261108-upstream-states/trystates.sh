#!/usr/bin/env bash
# Load each downloaded upstream savestate on the MLP1 against its disc from the ROM share, with the
# Flycastrophe release core (arm fcr-rel) in Leaf's RetroArch and the bench config (no
# RetroAchievements login). Per test: disc copied to the bench folder, state pushed as
# <disc>.state.auto, RetroArch started, frames at 8 s and 20 s, QUIT, log kept. A disc is removed
# once no later test needs it.
#   OUT=<dir> tools/trystates.sh
set -uo pipefail
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh
OUT="${OUT:?OUT}"; mkdir -p "$OUT"
SHARE="/Volumes/home/Roms/Myrient/RA - Sega Dreamcast"
DL=/Volumes/Storage/UMRK/tmp/flycastrophe-pgo/downloads
R="$DEV_DIR/roms"
ARM="${ARM:-fcr-rel}"
trap 'stop_ra; resume_launcher' EXIT

# label|disc file on the share|raw state
TESTS=(
  "spiderman-0|Spider-Man (USA).chd|$DL/2191-24507012/extracted/Spider-Man (USA).state.raw.state"
  "spiderman-1|Spider-Man (USA).chd|$DL/2191-24507012/extracted/Spider-Man (USA)_1.state.raw.state"
  "spiderman-2|Spider-Man (USA).chd|$DL/2191-24507012/extracted/Spider-Man (USA)_2.state.raw.state"
  "sa2|Sonic Adventure 2 (USA) (En,Ja,Fr,De,Es).chd|$DL/1778-18142060/extracted/Sonic.Adventure.2.v1.008.2001.Sega.NTSC.US.M5.state.txt.raw.state"
  "pso2|Phantasy Star Online Ver. 2 (USA) (En,Ja,Fr,De,Es).chd|$DL/1684-17340776/extracted/Phantasy Star Online Ver. 2 (USA) (En,Ja,Fr,De,Es).state.raw.state"
  "lol1610-ja|L.O.L. - Lack of Love (Japan).chd|$DL/1610-16735779/extracted/L.O.L. - Lack of Love.state.raw.state"
  "lol1033-ja|L.O.L. - Lack of Love (Japan).chd|$DL/1033-11333438/extracted/L.O.L. - Lack of Love.state.raw.state"
  "lol1610-en|L.O.L. - Lack of Love (Japan) (En) (v1.001).chd|$DL/1610-16735779/extracted/L.O.L. - Lack of Love.state.raw.state"
  "lol1033-en|L.O.L. - Lack of Love (Japan) (En) (v1.001).chd|$DL/1033-11333438/extracted/L.O.L. - Lack of Love.state.raw.state"
  "ecco|Ecco the Dolphin - Defender of the Future (USA) (En,Fr,De,Es).chd|$DL/1610-16739623/extracted/Ecco the Dolphin - Defender of the Future (USA) (En,Fr,De,Es).state.raw.state"
  "techromancer|Tech Romancer (USA).chd|$DL/1610-17165646/extracted/Tech Romancer.state.raw.state"
  "vigilante8|Vigilante 8 - 2nd Offense (USA).chd|$DL/1610-17165652/extracted/Vigilante 8 - 2nd Offense v1.000 (1999)(Activision)(NTSC)(US)[!].state.raw.state"
  "sonic|Sonic Adventure (USA) (En,Ja,Fr,De,Es) (Rev A).chd|$DL/1600-16664186/extracted/Sonic Adventure (USA) (En,Ja,Fr,De,Es) (Rev A).state3.raw.state"
  "evolution2|Evolution 2 - Far Off Promise (USA).chd|$DL/1284-13260715/extracted/Evolution 2 - Far Off Promise v1.000 (2000)(Ubi Soft)(NTSC)(US)[!]_4.state.raw.state"
)

if [ -n "${ONLY:-}" ]; then sel=(); for t in "${TESTS[@]}"; do case " $ONLY " in *" ${t%%|*} "*) sel+=("$t") ;; esac; done; TESTS=("${sel[@]}"); fi
prepare_device "$ARM" >/dev/null
current=""
for i in "${!TESTS[@]}"; do
  IFS='|' read -r label disc state <<<"${TESTS[$i]}"
  echo "== $label"
  [ -f "$state" ] || { echo "$label: no state at $state"; continue; }
  if [ "$disc" != "$current" ]; then
    [ -n "$current" ] && sh_ "rm -f '$R/$current'" >/dev/null
    adb_ push "$SHARE/$disc" "$R/$disc" >/dev/null || { echo "$label: disc push failed"; current=""; continue; }
    current="$disc"
  fi
  base="${disc%.*}"
  sh_ "rm -f '$DEV_DIR/states/'*; true" >/dev/null
  adb_ push "$state" "$DEV_DIR/states/$base.state.auto" >/dev/null
  write_ra_cfg 1
  sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
  pause_launcher
  if start_ra "$ARM" "$R/$disc"; then
    sleep 8; screenshot "$OUT/$label-08s.png" >/dev/null 2>&1
    sleep 12
    if sh_ "pidof retroarch" >/dev/null; then
      screenshot "$OUT/$label-20s.png" >/dev/null 2>&1
      ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
      sh_ "for i in \$(seq 1 50); do pidof retroarch >/dev/null || break; sleep 0.1; done; true" >/dev/null
    else
      echo "$label: RetroArch exited within 20 s"
    fi
  else
    echo "$label: start failed"
  fi
  adb_ exec-out cat "$DEV_DIR/retroarch.log" > "$OUT/$label-retroarch.log"
  grep -hE 'Loading state|Loading state failed|Failed to load state|Unsupported|terminate called|Game ID' "$OUT/$label-retroarch.log" | head -4
  stop_ra
done
[ -n "$current" ] && sh_ "rm -f '$R/$current'" >/dev/null
echo "done"
