#!/usr/bin/env bash
# Record a RetroArch input replay for the Flycastrophe bench: the stock core in
# Leaf's RetroArch started with -R (record from the start) and -e 0 (load the
# game's savestate as slot 0 first; -R ignores the auto-load), the drive script
# looped on the network pad, and RetroArch quit cleanly SECONDS later, which
# finishes the file. (The RECORD_REPLAY network command is not handled here.)
# The replay stores that state in its header, so playing it back (`bench.sh`
# with REPLAY=1) starts every arm on the same frame with the
# same input on every frame: the game moves, and it moves the same way.
#
#   flycastrophe/record-replay.sh <game> [seconds=100]
# Writes replays/<game>.replay (and keeps the previous one as .replay.prev).
set -euo pipefail

BENCH_HOST="${BENCH_HOST:-$(cd "$(dirname "$0")/.." && pwd)}"
. "$BENCH_HOST/lib-bench.sh"

game="${1:?game}"; seconds="${2:-100}"
rom="$(resolve_rom "$game")"
[ -n "$rom" ] || { echo "ROM for $game not found" >&2; exit 1; }
base="$(state_basename "$rom")"
state="$BENCH_HOST/states/upstream-$game.state"
drive="$BENCH_HOST/drive-$game.txt"
mkdir -p "$BENCH_HOST/replays"

cleanup() {
  set +e
  drive_stop
  stop_ra
  resume_launcher
}
trap cleanup EXIT HUP INT TERM

prepare_device stock
write_ra_cfg 0
# Player 2 off jawakad's paused virtual pad (its rumble upload stalls 30 s);
# no periodic checkpoints inside the replay.
sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'
     echo 'replay_checkpoint_interval = \"0\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
sh_ "rm -f '$DEV_DIR/states/'*; mkdir -p '$DEV_DIR/replays'; rm -f '$DEV_DIR/replays/$game.replay'; true" >/dev/null
adb_ push "$state" "$DEV_DIR/states/$base.state" >/dev/null
# lib-bench's launch.sh runs `exec $RA_BIN ...` unquoted, so the extra arguments ride along
RA_BIN="$RA_BIN -R $DEV_DIR/replays/$game.replay -e 0"

pause_launcher
start_ra stock "$rom"
drive_start "$drive"
sh_ "grep -iE 'replay|movie' '$DEV_DIR/retroarch.log' | head -5"
sh_ "test -s '$DEV_DIR/replays/$game.replay'" || sleep 2
echo "recording $game for $seconds s"
sleep "$seconds"
screenshot "$BENCH_HOST/replays/$game-recorded-end.png" >/dev/null 2>&1 || true
drive_stop
ra_cmd "quit" >/dev/null 2>&1 || true
for i in $(seq 1 40); do sh_ "pidof retroarch" >/dev/null || break; sleep 0.5; done
replay="$DEV_DIR/replays/$game.replay"
sh_ "test -s '$replay'" || { echo "no replay file" >&2; sh_ "tail -20 '$DEV_DIR/retroarch.log'"; exit 1; }
[ -f "$BENCH_HOST/replays/$game.replay" ] && mv -f "$BENCH_HOST/replays/$game.replay" "$BENCH_HOST/replays/$game.replay.prev"
adb_ pull "$replay" "$BENCH_HOST/replays/$game.replay" >/dev/null
ls -l "$BENCH_HOST/replays/$game.replay"
sh_ "grep -iE 'replay|movie|bsv' '$DEV_DIR/retroarch.log' | tail -6"
