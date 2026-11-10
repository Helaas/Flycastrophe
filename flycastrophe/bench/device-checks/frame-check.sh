#!/usr/bin/env bash
# Same picture from two cores: each game booted from the BIOS with no input on BASE and on NEW, both with
# FLYCASTROPHE_GLHASH=1, SECS seconds each; hashcmp.py then pairs their frames by what they were drawn from
# and compares the pixels. For renderer changes that must not change the picture.
#
# Threaded rendering is off for these runs: with it on, the emulation thread can rewrite a texture while
# the renderer decodes it, and about 1% of the frames of a game that streams textures (Headhunter) come
# out different from one run to the next of the same core. Where frames still differ, BASE runs once
# more and only the frames it reproduces itself count.
#   frame-check.sh OUT BASE_ARM NEW_ARM   [SECS=45] [ONLY="doa2 vf4"] [CARD=1: only games already on the device]
# Games from the NAS are copied to a temporary folder at the top of Leaf's card and removed again.
set -uo pipefail
BENCH_HOST="${BENCH_HOST:-$(cd "$(dirname "$0")/.." && pwd)}"
. "$BENCH_HOST/lib-bench.sh"
OUT="${1:?OUT}"; BASE="${2:?BASE_ARM}"; NEW="${3:?NEW_ARM}"; SECS="${SECS:-45}"
mkdir -p "$OUT"
DC="/Volumes/home/Roms/Myrient/RA - Sega Dreamcast"
CARD_DC="$LEAF_SD/Roms/DC"
TMP="$LEAF_SD/flycastrophe-bench-tmp"
R="$DEV_DIR/roms"
OPTIONS="$(mktemp)"
trap 'rm -f "$OPTIONS"' EXIT
sed 's/^reicast_threaded_rendering = .*/reicast_threaded_rendering = "disabled"/' "$BENCH_HOST/core-options.cfg" >"$OPTIONS"
export CORE_OPTIONS="$OPTIONS"

# name|rom on the device|host file to copy there first (none: already on the device)
GAMES=(
  "doa2|$CARD_DC/Dead or Alive 2 (USA).chd|"
  "powerstone|$CARD_DC/Power Stone (USA).chd|"
  "segarally2|$CARD_DC/Sega Rally 2 (USA).chd|"
  "daytona|$CARD_DC/Daytona USA 2001 (Europe) (En,Fr,De,Es).chd|"
  "spiderman|$CARD_DC/Spider-Man (USA).chd|"
  "ecco|$CARD_DC/Ecco the Dolphin - Defender of the Future (USA) (En,Fr,De,Es).chd|"
  "armada|$CARD_DC/Armada (USA).chd|"
  "sonicadventure|$CARD_DC/Sonic Adventure (USA) (En,Ja,Fr,De,Es) (Rev A).chd|"
  "headhunter|$CARD_DC/Headhunter (Europe) (EnFrDeEs).m3u|"
  "capsnk|$LEAF_SD/Roms/NAOMI/capsnk.zip|"
  "ggxx|$LEAF_SD/Roms/NAOMI/ggxx.zip|"
  "dolphin|$LEAF_SD/Roms/ATOMISWAVE/dolphin.zip|"
  "fotns|$LEAF_SD/Roms/ATOMISWAVE/fotns.zip|"
  "mslug6|$LEAF_SD/Roms/ATOMISWAVE/mslug6.zip|"
  "vf4|$R/vf4cart.zip|"
)
if [ "${CARD:-0}" != 1 ]; then
  GAMES+=(
    "mvc2|$TMP/mvc2.chd|$DC/Marvel vs. Capcom 2 (USA).chd"
    "rez|$TMP/rez.chd|$DC/Rez (Europe) (En,Ja,Fr,De,Es,It).chd"
    "shenmue|$TMP/shenmue1.chd|$DC/Shenmue (Europe) (En,Fr,De,Es)/Shenmue (Europe) (En,Fr,De,Es) (Disc 1).chd"
    "skies|$TMP/skies1.chd|$DC/Skies of Arcadia (Europe) (En,Fr,De,Es)/Skies of Arcadia (Europe) (En,Fr,De,Es) (Disc 1).chd"
    "soulcalibur|$TMP/soulcalibur.chd|$DC/Soulcalibur (Europe) (En,Fr,De,Es).chd"
    "jetsetradio|$TMP/jetsetradio.chd|$DC/Jet Set Radio (Europe) (En,Fr,De,Es).chd"
    "virtuatennis2|$TMP/virtuatennis2.chd|$DC/Virtua Tennis 2 - Sega Professional Tennis (Europe) (En,Fr,De,Es).chd"
    "thps2|$TMP/thps2.chd|$DC/Tony Hawk's Pro Skater 2 (USA).chd"
    "vf3tb|$TMP/vf3tb.chd|$DC/Virtua Fighter 3tb (USA).chd"
    "ikaruga|$TMP/ikaruga.chd|$DC/Ikaruga (Japan).chd"
  )
fi
if [ -n "${ONLY:-}" ]; then sel=(); for g in "${GAMES[@]}"; do case " $ONLY " in *" ${g%%|*} "*) sel+=("$g") ;; esac; done; GAMES=("${sel[@]}"); fi

for entry in "${GAMES[@]}"; do
  IFS='|' read -r name rom src <<<"$entry"
  if [ -n "$src" ]; then
    [ -f "$src" ] || { echo "$name: no $src"; continue; }
    sh_ "mkdir -p '$(dirname "$rom")'" >/dev/null </dev/null
    adb_ push "$src" "$rom" >/dev/null </dev/null || { echo "$name: copy failed"; continue; }
  fi
  OUT="$OUT" SECS="$SECS" GAMES="" DISCS="$name|$rom|" "$BENCH_HOST/flycastrophe/perf-run.sh" \
    "base|$BASE|FLYCASTROPHE_GLHASH=1" "new|$NEW|FLYCASTROPHE_GLHASH=1" </dev/null >"$OUT/$name.out" 2>&1
  result="$(python3 -I "$BENCH_HOST/flycastrophe/hashcmp.py" "$OUT/$name-base-r1.log" "$OUT/$name-new-r1.log" 2>&1 | tail -1)"
  case "$result" in
    *" 0 differ") ;;
    *)
      # frames differ: a second run of BASE tells which frames it reproduces itself
      OUT="$OUT" SECS="$SECS" GAMES="" DISCS="$name|$rom|" "$BENCH_HOST/flycastrophe/perf-run.sh" \
        "control|$BASE|FLYCASTROPHE_GLHASH=1" </dev/null >>"$OUT/$name.out" 2>&1
      result="$(python3 -I "$BENCH_HOST/flycastrophe/hashcmp.py" "$OUT/$name-base-r1.log" "$OUT/$name-new-r1.log" "$OUT/$name-control-r1.log" 2>&1 | tail -1)" ;;
  esac
  if [ -n "$src" ]; then sh_ "rm -f '$rom'" >/dev/null </dev/null; fi
  echo "$name: $result"
done | tee "$OUT/frame-check.txt"
sh_ "rmdir '$TMP' 2>/dev/null; true" >/dev/null </dev/null
