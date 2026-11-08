#!/usr/bin/env bash
# Flycastrophe A/B bench on the MLP1. Arms are a RetroArch + core pair:
#   gles      Leaf's RetroArch + the card's stock flycast core (out/stock_libretro.so)
#   vk        the Phase 0 Vulkan RetroArch + the stock core (needs /userdata/umrk-dev/flycastrophe)
#   fcr-NAME  Leaf's RetroArch + out/fcr-NAME_libretro.so (a Flycastrophe build)
# The first arm is the baseline the summary compares the others against.
#
#   flycastrophe/bench.sh [rounds=3] [warmup=15] [seconds=60]
#   ARMS="gles fcr-base" GAMES="crazy-taxi" flycastrophe/bench.sh 1     # subset
#   UNCAPPED=1 DRIVE=0 TAG=uncapped flycastrophe/bench.sh 3 10 30
#   REPLAY=1 [UNCAPPED=1] flycastrophe/bench.sh 3 10 60
#       play replays/<game>.replay (record-replay.sh) instead of the state + drive
#       script: same input on the same frames for every arm, so the game moves the
#       same way. Also records replay_end_s, start to the end of the replay.
#       Replays must outlast warmup + 3 s + the window (record-replay.sh: 100 s).
#       vsync and audio sync off, no input: throughput of core + renderer
#
# Reuses the Dreamcast bench harness (tmp/dc-core-bench/lib-bench.sh): its
# Leaf-mirroring retroarch.cfg, network-pad drive scripts, auto-loaded
# upstream-*.state savestates, performance governors and GET_PERF_INFO
# sampling. On top of that it records, per run:
#   - startup: RetroArch process start to the first GET_INFO reply, timed on
#     the device every 100 ms (includes content load and the state load);
#   - CPU per RetroArch thread, Weston and the whole SoC over the window;
#   - GPU load from devfreq at every 5 s sample.
#
# Rounds 1..N interleave the arms, rotating the order each round. WARMUP_ROUND=1
# adds a discarded round 0 first (it mattered for Vulkan's pipeline cache; GLES
# has nothing to warm, so it is off by default).
#
# Presets (Flycastrophe dev, 2026-11-07):
#   quick check  REPLAY=1 UNCAPPED=1 flycastrophe/bench.sh 1 10 45   (~5 min)
#   merge check  REPLAY=1 UNCAPPED=1 flycastrophe/bench.sh 2 10 60   (~10 min)
# Rep-to-rep spread is ~0.5-2% (up to ~4% on a still SA2), so a change under
# ~2% does not show either way.
# Between runs the SoC cools below COOL_MC.
set -uo pipefail

BENCH_HOST="${BENCH_HOST:-$(cd "$(dirname "$0")/.." && pwd)}"
. "$BENCH_HOST/lib-bench.sh"

rounds="${1:-3}"; warmup="${2:-15}"; seconds="${3:-60}"
read -r -a arms <<<"${ARMS:-gles vk}"
read -r -a games <<<"${GAMES:-crazy-taxi sa2}"
COOL_MC="${COOL_MC:-58000}"
UNCAPPED="${UNCAPPED:-0}"
DRIVE="${DRIVE:-1}"   # 0: no input, the state just plays (deterministic scene)
REPLAY="${REPLAY:-0}" # 1: replays/<game>.replay, frame-locked input (no drive script)
[ "$REPLAY" = 1 ] && DRIVE=0
RA_EXTRA_ARGS=""
CORE_ARM=stock   # set per run by arm_env
VK_DIR=/userdata/umrk-dev/flycastrophe
LEAF_RA_BIN="$PLATFORM_ROOT/bin/retroarch"
STAMP="$(date +%Y%m%d-%H%M%S)"
SUITE="$BENCH_HOST/evidence/fcr-phase0-$STAMP${TAG:+-$TAG}"
mkdir -p "$SUITE"
LOG="$SUITE/suite.log"

arm_env() { # arm -> sets RA_BIN and EXTRA_ENV for lib-bench's launch.sh
    case "$1" in
        gles)   RA_BIN="$LEAF_RA_BIN"; EXTRA_ENV=""; CORE_ARM=stock ;;
        vk)     RA_BIN="$VK_DIR/bin/retroarch"; EXTRA_ENV=". $VK_DIR/env.sh"; CORE_ARM=stock ;;
        fcr-*)  RA_BIN="$LEAF_RA_BIN"; EXTRA_ENV=""; CORE_ARM="$1" ;;
        fastumrk) RA_BIN="$LEAF_RA_BIN"; EXTRA_ENV=""; CORE_ARM=fastumrk ;;
        *) echo "unknown arm $1" >&2; return 1 ;;
    esac
}

cool() {
    local t i
    for i in $(seq 1 24); do
        t="$(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')"
        [ "${t:-0}" -le "$COOL_MC" ] && return 0
        sleep 5
    done
}

# start_timed <rom> : lib-bench's launch.sh, then a device-side wait for the
# first GET_INFO reply. Prints startup_s.
start_timed() {
    local rom="$1"
    sh_ "pkill -x retroarch 2>/dev/null; true" >/dev/null
    sleep 1
    sh_ "cat > '$DEV_DIR/launch.sh'" <<SH
#!/bin/sh
export XDG_RUNTIME_DIR=/var/run
export WAYLAND_DISPLAY=wayland-0
export SDL_VIDEODRIVER=wayland
export PULSE_SERVER=unix:/tmp/pulse-socket
export HOME="$DEV_DIR/home"
${EXTRA_ENV:-}
cd "$DEV_DIR" || exit 1
exec $RA_BIN --config "$DEV_DIR/retroarch.cfg" -L "$DEV_DIR/cores/${CORE_ARM}_libretro.so" "$rom" $RA_EXTRA_ARGS --verbose >"$DEV_DIR/retroarch.log" 2>&1 </dev/null
SH
    sh_ "chmod 755 '$DEV_DIR/launch.sh'
setsid '$DEV_DIR/launch.sh' </dev/null >/dev/null 2>&1 &
pid=''
for i in \$(seq 1 200); do pid=\$(pidof retroarch); [ -n \"\$pid\" ] && break; sleep 0.05; done
[ -n \"\$pid\" ] || { echo startup=no_process; exit 0; }
st=\$(cut -d' ' -f22 /proc/\$pid/stat)
echo start_uptime_s=\$(awk -v s=\$st 'BEGIN{printf \"%.2f\", s/100}')
for i in \$(seq 1 600); do
  r=\$($RA_CTL --timeout-ms 200 --port $CMD_PORT raw-request GET_INFO 2>/dev/null)
  case \"\$r\" in *GET_INFO*) u=\$(cut -d' ' -f1 /proc/uptime); awk -v u=\$u -v s=\$st 'BEGIN{printf \"startup_s=%.2f\\n\", u - s/100}'; exit 0;; esac
  pidof retroarch >/dev/null || { echo startup=died; exit 0; }
  sleep 0.1
done
echo startup=timeout"
}

# cpu_snapshot : uptime, /proc/stat cpu line, weston and per-thread RetroArch
# jiffies, one line each.
cpu_snapshot() {
    sh_ 'echo "uptime $(cut -d" " -f1 /proc/uptime)"
head -1 /proc/stat
w=$(pidof weston | cut -d" " -f1); [ -n "$w" ] && echo "weston $(cut -d" " -f14,15 /proc/$w/stat)"
p=$(pidof retroarch | cut -d" " -f1)
[ -n "$p" ] && for t in /proc/$p/task/*; do
  s=$(cat $t/stat 2>/dev/null) || continue
  c=${s#*(}; c=${c%%)*}; rest=${s##*) }
  set -- $rest
  echo "thread ${t##*/} $(echo "$c" | tr " " "_") ${12} ${13}"
done'
}

run_one() { # arm game round
    local arm="$1" game="$2" round="$3"
    local rom base state drive out started result elapsed probe
    arm_env "$arm" || return 1
    rom="$(resolve_rom "$game")"
    [ -n "$rom" ] || { echo "ROM for $game not found" >&2; return 1; }
    base="$(state_basename "$rom")"
    state="$BENCH_HOST/states/${STATE_FAMILY:-$(state_family "$CORE_ARM")}-$game.state"  # STATE_FAMILY: another generation's states, where the core loads them
    drive="$BENCH_HOST/drive-$game.txt"
    python3 "$BENCH_HOST/verify_state.py" "$state" >/dev/null || { echo "state $state incomplete" >&2; return 1; }
    out="$SUITE/$game-$arm-r$round"
    mkdir -p "$out"

    prepare_device "$CORE_ARM" || return 1
    if [ "$REPLAY" = 1 ]; then write_ra_cfg 0; else write_ra_cfg 1; fi
    # Player 2 defaults to joypad 1, the virtual pad that loong_pangu (jawakad)
    # owns. With it paused, SDL's first rumble upload to that pad waits out the
    # kernel's 30 s uinput timeout and stalls startup. The bench drives player 1
    # through the network pad, so player 2 can point at an index with no pad.
    sh_ "echo 'input_player2_joypad_index = \"7\"' >> '$DEV_DIR/retroarch.cfg'" >/dev/null
    # UNCAPPED=1: vsync and audio sync off, so the frame rate is how fast the
    # core and the renderer can go, not the panel's 60 Hz. Edited in place:
    # write_ra_cfg already sets both keys.
    if [ "$UNCAPPED" = 1 ]; then
        sh_ "sed -i -e 's/^video_vsync = .*/video_vsync = \"false\"/' -e 's/^audio_sync = .*/audio_sync = \"false\"/' '$DEV_DIR/retroarch.cfg'" >/dev/null
    fi
    sh_ "rm -f '$DEV_DIR/states/'* '$DEV_DIR/screenshots/'*; true" >/dev/null
    if [ "$REPLAY" = 1 ]; then
        replay="$BENCH_HOST/replays/$game.replay"
        [ -f "$replay" ] || { echo "no $replay (record-replay.sh $game)" >&2; return 1; }
        sh_ "mkdir -p '$DEV_DIR/replays'" >/dev/null
        adb_ push "$replay" "$DEV_DIR/replays/$game.replay" >/dev/null
        RA_EXTRA_ARGS="-P $DEV_DIR/replays/$game.replay --eof-exit"
    else
        RA_EXTRA_ARGS=""
        adb_ push "$state" "$DEV_DIR/states/$base.state.auto" >/dev/null
    fi
    adb_ exec-out cat "$DEV_DIR/retroarch.cfg" >"$out/retroarch.cfg"
    {
        echo "arm=$arm"; echo "game=$game"; echo "round=$round"; echo "rom=$rom"; echo "core_arm=$CORE_ARM"
        echo "core_sha256=$CORE_SHA"; echo "ra_bin=$RA_BIN"; echo "extra_env=$EXTRA_ENV"
        echo "ra_sha256=$(sh_ "sha256sum '$RA_BIN'" | awk '{print $1}')"
        echo "state_sha256=$(shasum -a 256 "$state" | awk '{print $1}')"
        echo "warmup_s=$warmup"; echo "seconds=$seconds"; echo "start_utc=$(date -u +%FT%TZ)"
        echo "uncapped=$UNCAPPED"; echo "drive=$DRIVE"; echo "replay=$REPLAY"
        [ "$REPLAY" = 1 ] && echo "replay_sha256=$(shasum -a 256 "$BENCH_HOST/replays/$game.replay" | awk '{print $1}')"
        grep -E '^(video_vsync|audio_sync|input_player2_joypad_index) ' "$out/retroarch.cfg" | tr -d '"' | sed 's/ = /=cfg_/'
    } >"$out/meta.txt"

    ORIG_GOV_CPU="$(sh_ 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"
    ORIG_GOV_GPU="$(sh_ 'cat /sys/class/devfreq/fde60000.gpu/governor')"
    ORIG_GOV_DMC="$(sh_ 'cat /sys/class/devfreq/dmc/governor')"
    GOV_SET=1
    sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$c/cpufreq/scaling_governor 2>/dev/null; done
         echo performance > /sys/class/devfreq/fde60000.gpu/governor
         echo performance > /sys/class/devfreq/dmc/governor; true" >/dev/null
    echo "temp_start=$(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')" >>"$out/meta.txt"

    pause_launcher
    started="$(start_timed "$rom")"
    echo "$started" >>"$out/meta.txt"
    case "$started" in *startup_s=*) ;; *) echo "result=start_failed" >>"$out/meta.txt"; finish_run "$out"; return 1 ;; esac
    start_uptime="$(echo "$started" | sed -n 's/^start_uptime_s=//p')"

    [ "$DRIVE" = 1 ] && drive_start "$drive"
    sleep "$warmup"
    if ! sh_ "pidof retroarch" >/dev/null; then echo "result=crash_warmup" >>"$out/meta.txt"; finish_run "$out"; return 1; fi

    probe='u=$(cut -d" " -f1 /proc/uptime)
p=$('"$RA_CTL"' --timeout-ms 3000 --port '"$CMD_PORT"' raw-request GET_PERF_INFO 2>/dev/null | tr "\n" " ")
pid=$(pidof retroarch | cut -d" " -f1)
printf "uptime=%s %s temp=%s cpu=%s gpu=%s dmc=%s gpuload=%s rss_kb=%s\n" "$u" "$p" \
  "$(cat /sys/class/thermal/thermal_zone0/temp)" \
  "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)" \
  "$(cat /sys/class/devfreq/fde60000.gpu/cur_freq)" \
  "$(cat /sys/class/devfreq/dmc/cur_freq)" \
  "$(cut -d@ -f1 /sys/class/devfreq/fde60000.gpu/load)" \
  "$( [ -n "$pid" ] && awk "/VmRSS/{print \$2}" /proc/$pid/status)"'

    screenshot "$out/start.png" >/dev/null 2>&1 || true
    sleep 3
    : >"$out/samples.txt"
    cpu_snapshot >"$out/cpu-start.txt"
    sh_ "$probe" >>"$out/samples.txt"
    elapsed=0; result=ok
    while [ "$elapsed" -lt "$seconds" ]; do
        sleep 1; elapsed=$((elapsed + 1))
        if [ $((elapsed % 5)) -eq 0 ]; then
            if ! sh_ "pidof retroarch" >/dev/null; then result="crash_at_${elapsed}s"; break; fi
            sh_ "$probe" >>"$out/samples.txt"
        fi
    done
    [ "$result" = ok ] && cpu_snapshot >"$out/cpu-end.txt"
    [ "$result" = ok ] && { screenshot "$out/end.png" >/dev/null 2>&1 || true; }
    if [ "$REPLAY" = 1 ] && [ "$result" = ok ]; then
        # how long the whole replay took: until RetroArch logs its end. (--eof-exit does
        # not quit RetroArch 1.22.2: stopping the replay clears the end flag first.)
        ended="$(sh_ "for i in \$(seq 1 3000); do grep -q 'replay movie playback ended' '$DEV_DIR/retroarch.log' && break; pidof retroarch >/dev/null || break; sleep 0.1; done; grep -q 'replay movie playback ended' '$DEV_DIR/retroarch.log' && cut -d' ' -f1 /proc/uptime || echo not-ended")"
        case "$ended" in
            ''|not-ended) echo "replay_end=not-ended" >>"$out/meta.txt" ;;
            *) awk -v e="$ended" -v s="$start_uptime" 'BEGIN{printf "replay_end_s=%.2f\n", e - s}' >>"$out/meta.txt" ;;
        esac
    fi
    echo "result=$result" >>"$out/meta.txt"
    echo "temp_end=$(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')" >>"$out/meta.txt"
    finish_run "$out"
}

finish_run() { # out
    drive_stop
    adb_ exec-out cat "$DEV_DIR/retroarch.log" >"$1/retroarch.log" 2>/dev/null
    stop_ra
    resume_launcher
    if [ "${GOV_SET:-0}" = 1 ]; then
        [ -n "$ORIG_GOV_CPU" ] && sh_ "for c in /sys/devices/system/cpu/cpu[0-9]*; do echo '$ORIG_GOV_CPU' > \$c/cpufreq/scaling_governor 2>/dev/null; done; true" >/dev/null
        [ -n "$ORIG_GOV_GPU" ] && sh_ "echo '$ORIG_GOV_GPU' > /sys/class/devfreq/fde60000.gpu/governor; true" >/dev/null
        [ -n "$ORIG_GOV_DMC" ] && sh_ "echo '$ORIG_GOV_DMC' > /sys/class/devfreq/dmc/governor; true" >/dev/null
        GOV_SET=0
    fi
    sh_ "dmesg | grep -iE 'mali|kbase|gpu fault|drm.*error|segfault|oom' | tail -5; true" >"$1/dmesg-tail.txt"
}

on_exit() { set +e; [ "${GOV_SET:-0}" = 1 ] && { mkdir -p "$SUITE/aborted"; finish_run "$SUITE/aborted"; }; resume_launcher; }
trap on_exit EXIT HUP INT TERM

n=${#arms[@]}
echo "$(date -u +%T) suite $SUITE rounds=$rounds warmup=$warmup seconds=$seconds arms=${arms[*]} games=${games[*]}" | tee -a "$LOG"
WARMUP_ROUND="${WARMUP_ROUND:-0}"
for round in $(seq $((WARMUP_ROUND ? 0 : 1)) "$rounds"); do
    for game in "${games[@]}"; do
        for i in $(seq 0 $((n - 1))); do
            arm="${arms[$(( (i + round) % n ))]}"
            cool
            echo "$(date -u +%T) round=$round game=$game arm=$arm temp=$(sh_ 'cat /sys/class/thermal/thermal_zone0/temp')" | tee -a "$LOG"
            run_one "$arm" "$game" "$round" >>"$LOG" 2>&1
            rc=$?
            [ "$rc" -eq 0 ] || echo "$(date -u +%T)   FAILED rc=$rc" | tee -a "$LOG"
            grep -h '^startup\|^result' "$SUITE/$game-$arm-r$round/meta.txt" 2>/dev/null | tr '\n' ' ' | sed 's/^/    /' | tee -a "$LOG"; echo | tee -a "$LOG"
        done
    done
done
echo "$(date -u +%T) suite done" | tee -a "$LOG"
ARMS="${arms[*]}" python3 -I "$(dirname "$0")/summarize.py" "$SUITE" | tee "$SUITE/summary.md"
