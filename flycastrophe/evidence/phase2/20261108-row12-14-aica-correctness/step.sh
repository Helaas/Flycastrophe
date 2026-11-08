#!/usr/bin/env bash
# step.sh start ARM ROM | step.sh press "TOKENS" [WAIT] SHOTNAME | step.sh stop
set -uo pipefail
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh >/dev/null 2>&1
D=/private/tmp/claude-501/-Users-umrk--claude-spares-spare-xOPgb3/906d413b-b4b6-4b53-8e76-bbab2ce48996/scratchpad/n2/out/steps
mkdir -p "$D"
case "$1" in
  start)
    prepare_device "$2" >/dev/null
    write_ra_cfg 0
    sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
    pause_launcher
    start_ra "$2" "$3" && echo started ;;
  press)
    for t in $2; do sh_ "'$DEV_DIR/rapad' $PAD_PORT --gap 0 --hold 120 $t" >/dev/null; sleep 0.6; done
    sleep "${3:-1}"
    screenshot "$D/$4.png" >/dev/null 2>&1
    sips -s format jpeg -Z 360 "$D/$4.png" --out "$D/$4.jpg" >/dev/null && echo "$D/$4.jpg" ;;
  stop)
    stop_ra; resume_launcher ;;
esac
