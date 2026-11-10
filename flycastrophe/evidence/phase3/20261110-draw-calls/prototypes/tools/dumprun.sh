#!/usr/bin/env bash
# One emulated frame (by its input hash) dumped from a base run and from prototype runs.
set -uo pipefail
S="$(cd "$(dirname "$0")" && pwd)"; D=/userdata/dc-core-bench; mkdir -p "$S/dumps"
while read -r g h; do
  OUT="$S/runs/dump" SECS=14 SHOT=0 GAMES="$g" "$S/glrun.sh" \
    "base|fcr-dcp5|FLYCASTROPHE_GLHASH=1 FLYCASTROPHE_GLDUMP=$h:$D/dump-base.raw" \
    "RM|fcr-dcp5|FLYCASTROPHE_GLHASH=1 FLYCASTROPHE_DC=65 FLYCASTROPHE_GLDUMP=$h:$D/dump-RM.raw" \
    "RMG|fcr-dcp5|FLYCASTROPHE_GLHASH=1 FLYCASTROPHE_DC=193 FLYCASTROPHE_GLDUMP=$h:$D/dump-RMG.raw" </dev/null 2>&1 | grep -v pushed | cut -c1-70
  for l in base RM RMG; do
    adb -s b1622a9e81b735ad pull "$D/dump-$l.raw" "$S/dumps/$g-$l.raw" </dev/null >/dev/null 2>&1 || echo "no dump $g $l"
    adb -s b1622a9e81b735ad shell "rm -f $D/dump-$l.raw" </dev/null
  done
done <<LIST
sa2 94aeea17a867367c
nfl2k2 c328fc893bbc10b4
LIST
