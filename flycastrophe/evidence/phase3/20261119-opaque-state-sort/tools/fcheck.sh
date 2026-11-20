#!/usr/bin/env bash
# fcheck.sh OUT "label|arm|core-options-file" ... : the prototype's 29 scenes (24 games booted from the BIOS with
# no input, 5 savestate scenes), each run once per arm with FLYCASTROPHE_GLHASH=1 and threaded rendering off
# (frames then reproduce run to run), the first arm twice (the second run is the control). hashcmp.py then pairs
# every other arm's frames with the first's by what they were drawn from. ONLY="a b" for a subset.
set -uo pipefail
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; shift; mkdir -p "$OUT"
DC="/Volumes/home/Roms/Myrient/RA - Sega Dreamcast"
CARD_DC="$LEAF_SD/Roms/DC"; TMP="$LEAF_SD/flycastrophe-bench-tmp"; R="$DEV_DIR/roms"
CT="$(resolve_rom crazy-taxi)"; S=$BENCH_HOST/states
# name|rom on the device|host file to copy there first|state|secs
SCENES=(
  "crazy-taxi|$CT||$S/upstream-crazy-taxi.state|40"
  "sa2|$CARD_DC/Sonic Adventure 2 (Europe) (En,Ja,Fr,De,Es).chd||$S/upstream-sa2.state|40"
  "sa2ce|$CARD_DC/Sonic Adventure 2 (Europe) (En,Ja,Fr,De,Es).chd||$S/sa2-hero-intro.state|100"
  "armada-play|$CARD_DC/Armada (USA).chd||$S/armada-base.state|40"
  "nfl2k2|$CARD_DC/NFL 2K2 (USA).chd||/Volumes/Storage/UMRK/tmp/flycastrophe-pgo/kcw/states/nfl2k2-play.state|60"
  "doa2|$CARD_DC/Dead or Alive 2 (USA).chd|||45"
  "powerstone|$CARD_DC/Power Stone (USA).chd|||45"
  "segarally2|$CARD_DC/Sega Rally 2 (USA).chd|||45"
  "daytona|$CARD_DC/Daytona USA 2001 (Europe) (En,Fr,De,Es).chd|||45"
  "spiderman|$CARD_DC/Spider-Man (USA).chd|||45"
  "ecco|$CARD_DC/Ecco the Dolphin - Defender of the Future (USA) (En,Fr,De,Es).chd|||45"
  "sonicadventure|$CARD_DC/Sonic Adventure (USA) (En,Ja,Fr,De,Es) (Rev A).chd|||45"
  "headhunter|$CARD_DC/Headhunter (Europe) (EnFrDeEs).m3u|||45"
  "capsnk|$LEAF_SD/Roms/NAOMI/capsnk.zip|||45"
  "ggxx|$LEAF_SD/Roms/NAOMI/ggxx.zip|||45"
  "dolphin|$LEAF_SD/Roms/ATOMISWAVE/dolphin.zip|||45"
  "fotns|$LEAF_SD/Roms/ATOMISWAVE/fotns.zip|||45"
  "mslug6|$LEAF_SD/Roms/ATOMISWAVE/mslug6.zip|||45"
  "vf4|$R/vf4cart.zip|||45"
  "mvc2|$TMP/mvc2.chd|$DC/Marvel vs. Capcom 2 (USA).chd||45"
  "rez|$TMP/rez.chd|$DC/Rez (Europe) (En,Ja,Fr,De,Es,It).chd||45"
  "shenmue|$TMP/shenmue1.chd|$DC/Shenmue (Europe) (En,Fr,De,Es)/Shenmue (Europe) (En,Fr,De,Es) (Disc 1).chd||45"
  "skies|$TMP/skies1.chd|$DC/Skies of Arcadia (Europe) (En,Fr,De,Es)/Skies of Arcadia (Europe) (En,Fr,De,Es) (Disc 1).chd||45"
  "soulcalibur|$TMP/soulcalibur.chd|$DC/Soulcalibur (Europe) (En,Fr,De,Es).chd||45"
  "jetsetradio|$TMP/jetsetradio.chd|$DC/Jet Set Radio (Europe) (En,Fr,De,Es).chd||45"
  "virtuatennis2|$TMP/virtuatennis2.chd|$DC/Virtua Tennis 2 - Sega Professional Tennis (Europe) (En,Fr,De,Es).chd||45"
  "thps2|$TMP/thps2.chd|$DC/Tony Hawk's Pro Skater 2 (USA).chd||45"
  "vf3tb|$TMP/vf3tb.chd|$DC/Virtua Fighter 3tb (USA).chd||45"
  "ikaruga|$TMP/ikaruga.chd|$DC/Ikaruga (Japan).chd||45"
)
if [ -n "${ONLY:-}" ]; then sel=(); for g in "${SCENES[@]}"; do case " $ONLY " in *" ${g%%|*} "*) sel+=("$g") ;; esac; done; SCENES=("${sel[@]}"); fi
arms=("$@"); IFS='|' read -r blabel barm bopts <<<"${arms[0]}"
runs=("${arms[0]}" "control|$barm|$bopts" "${arms[@]:1}")
for entry in "${SCENES[@]}"; do
  IFS='|' read -r name rom src state secs <<<"$entry"
  if [ -n "$src" ]; then
    [ -f "$src" ] || { echo "$name: no $src"; continue; }
    sh_ "mkdir -p '$(dirname "$rom")'" >/dev/null </dev/null
    adb_ push "$src" "$rom" >/dev/null </dev/null || { echo "$name: copy failed"; continue; }
  fi
  for run in "${runs[@]}"; do
    IFS='|' read -r label arm opts <<<"$run"
    OUT="$OUT" SECS="$secs" GAMES="" DISCS="$name|$rom|$state" CORE_OPTIONS="$opts" "$BENCH_HOST/flycastrophe/perf-run.sh" \
      "$label|$arm|FLYCASTROPHE_GLHASH=1" </dev/null >>"$OUT/$name.out" 2>&1
  done
  [ -n "$src" ] && sh_ "rm -f '$rom'" >/dev/null </dev/null
  for run in "${arms[@]:1}"; do
    IFS='|' read -r label arm opts <<<"$run"
    echo "$name $label: $(python3 -I "$BENCH_HOST/flycastrophe/hashcmp.py" "$OUT/$name-$blabel-r1.log" "$OUT/$name-$label-r1.log" "$OUT/$name-control-r1.log" 2>&1 | tail -1)"
  done
done | tee -a "$OUT/fcheck.txt"
sh_ "rmdir '$TMP' 2>/dev/null; true" >/dev/null </dev/null
