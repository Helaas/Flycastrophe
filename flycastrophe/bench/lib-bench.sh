# Shared helpers for the Dreamcast core bench (sourced by ra-session.sh and
# bench-v2.sh). Host side is macOS bash; device side is the MLP1 over ADB.
#
# Design notes (see umrk-workspace/plans/dc-libretro-xtreme-benchmark.md):
#   * Input is RetroArch's network gamepad driven by rapad (UDP 55400), so there
#     is no uinput device and no SDL joypad index involved.
#   * Never send GET_STATUS (kills Flycast cores; see §1.1). GET_PERF_INFO,
#     SCREENSHOT, SAVE_STATE_SLOT and LOAD_STATE_SLOT are safe.
#   * Never call kmsgrab or weston-screenshooter (§1.2, §1.3).
#   * The device's /tmp is RAM-backed tmpfs on a 955 MB device, so everything
#     large lives under /userdata (eMMC) instead.
#   * RetroArch settings mirror the production defaults/retroarch.cfg (pulse,
#     48 kHz, 128 ms latency, gl/sdl_gl, no threaded video, no hard sync) so the
#     numbers are comparable with shipped behaviour; audio is muted (gain 0,
#     pacing unchanged) for automated runs.

BENCH_HOST="${BENCH_HOST:-/Volumes/Storage/UMRK/tmp/dc-core-bench}"
DEV_DIR="${DEV_DIR:-/userdata/dc-core-bench}"
# Config profile. "leaf" is the production-mirroring arm this harness was built
# around; "darkos" overlays dArkOS's Miniloong RetroArch + core-option deltas
# (threaded video, alsathread, adaptive frame skipping). Selected per run with
# BENCH_PROFILE so the existing leaf numbers stay comparable.
BENCH_PROFILE="${BENCH_PROFILE:-leaf}"
CMD_PORT=55358
PAD_PORT=55400
PLATFORM_ROOT=/mnt/sdcard/.system/leaf/platforms/mlp1
# RA_BIN may point at another RetroArch build (Flycastrophe Phase 0 runs the
# pak's Vulkan RetroArch from /userdata with EXTRA_ENV).
RA_BIN="${RA_BIN:-$PLATFORM_ROOT/bin/retroarch}"
RA_CTL="$PLATFORM_ROOT/launcher/bin/jawaka-retroarchctl"
INFO_DIR="$PLATFORM_ROOT/info"
LAUNCHER_PROCS="loong_pangu jawakad jawaka-launcher jawaka-menu"

# Resolve the MLP1 by model, not by serial (several units exist). The bench
# pins its unit in .adb-serial so a second MLP1 plugged in later can never be
# picked up mid-run; with a pin there is no fallback scan.
if [ -z "${ADB_SERIAL:-}" ] && [ -f "$BENCH_HOST/.adb-serial" ]; then
  ADB_SERIAL="$(cat "$BENCH_HOST/.adb-serial")"
  adb -s "$ADB_SERIAL" shell 'cat /proc/device-tree/model 2>/dev/null' | tr -d '\0' | grep -q 'RK3566' \
    || { echo "pinned MLP1 $ADB_SERIAL (.adb-serial) is not online" >&2; exit 1; }
fi
if [ -z "${ADB_SERIAL:-}" ]; then
  for s in $(adb devices | awk 'NR>1 && $2=="device"{print $1}'); do
    if adb -s "$s" shell 'cat /proc/device-tree/model 2>/dev/null' | tr -d '\0' | grep -q 'RK3566'; then
      ADB_SERIAL="$s"; break
    fi
  done
fi
[ -n "${ADB_SERIAL:-}" ] || { echo "no MLP1 (RK3566) on adb" >&2; exit 1; }
ADB=(adb -s "$ADB_SERIAL")
adb_() { "${ADB[@]}" "$@"; }
sh_() { "${ADB[@]}" shell "$@" 2>/dev/null | tr -d '\r'; }
ra_cmd() { sh_ "$RA_CTL --timeout-ms 3000 --port $CMD_PORT $*"; }

# arm -> host core path
core_src() {
  case "$1" in
    upstream) echo "$BENCH_HOST/out/upstream_libretro.so" ;;
    # the card's own Leaf flycast core (c3763d8, sha256 6ac785f8...)
    stock)    echo "$BENCH_HOST/out/stock_libretro.so" ;;
    # Flycastrophe builds (flycastrophe/bench.sh): out/fcr-<name>_libretro.so
    fcr-*)    echo "$BENCH_HOST/out/$1_libretro.so" ;;
    # Leaf's shipped flycast_fast_umrk (flycast 4c293f3 + PGO), pulled from the card
    fastumrk) echo "$BENCH_HOST/out/fastumrk_libretro.so" ;;
    xtreme)   echo "$BENCH_HOST/out/flycast-xtreme_libretro.so" ;;
    ch2024)   echo "$BENCH_HOST/out/ch2024_libretro.so" ;;
    r[0-9])   echo "$BENCH_HOST/out/$1-km_morpheuscast_xtreme_libretro.so" ;;
    f22*)  # our builds of upstream flycast 4c293f3 (2022 generation)
        echo "$BENCH_HOST/out/$1_libretro.so" ;;
    *)  # any other name is a MorpheusCast build variant in out/
        f="$BENCH_HOST/out/$1-km_morpheuscast_xtreme_libretro.so"
        [ -f "$f" ] || { echo "unknown arm: $1 (no $f)" >&2; return 1; }
        echo "$f" ;;
  esac
}

# arm -> savestate family (MorpheusCast rungs share one source tree and state
# format; the other two cores do not interchange states).
state_family() {
  case "$1" in
    upstream) echo upstream ;;
    stock)    echo upstream ;;
    fcr-*)    echo upstream ;;
    fastumrk) echo xtreme ;;   # 2022 generation
    xtreme)   echo xtreme ;;
    # ch2024 is the christianhaitian/retroarch-cores rg503 aarch64 prebuilt,
    # byte-identical to flycast-xtreme_libretro.so (the "xtreme" arm) and to the
    # core dArkOS installs, so it reuses that family's states.
    ch2024)   echo xtreme ;;
    # our 2022-generation builds share that generation's savestate format
    f22*)     echo xtreme ;;
    r[0-9])   echo morpheus ;;
    *)        echo morpheus ;;   # every other arm is a MorpheusCast variant
  esac
}

# game -> ROM path. The two SD cards swap mount points across reboots, so
# search both.
resolve_rom() {
  local pattern
  case "$1" in
    crazy-taxi) pattern='Crazy Taxi (USA).chd' ;;
    sa2)        pattern='Sonic Adventure 2 (Europe) (En,Ja,Fr,De,Es).chd' ;;
    *) echo "unknown game: $1" >&2; return 1 ;;
  esac
  sh_ "for d in /mnt/sdcard/Roms/DC /media/sdcard1/Roms/DC; do [ -f \"\$d/$pattern\" ] && { echo \"\$d/$pattern\"; break; }; done; true"
}

pause_launcher() {
  sh_ "for n in $LAUNCHER_PROCS; do for p in \$(pidof \$n 2>/dev/null); do kill -STOP \$p 2>/dev/null; done; done; true" >/dev/null
}
resume_launcher() {
  sh_ "for n in $LAUNCHER_PROCS; do for p in \$(pidof \$n 2>/dev/null); do kill -CONT \$p 2>/dev/null; done; done; true" >/dev/null
}

# profile -> host core-options file. Any profile that has its own
# `core-options-<profile>.cfg` overlay wins; the untouched leaf baseline
# (`BENCH_PROFILE=leaf`) has no file and uses core-options.cfg.
profile_core_options() {
  local f="$BENCH_HOST/core-options-$BENCH_PROFILE.cfg"
  [ -f "$f" ] && { echo "$f"; return; }
  case "$BENCH_PROFILE" in
    darkos|dk-*) echo "$BENCH_HOST/core-options-darkos.cfg" ;;
    *)           echo "$BENCH_HOST/core-options.cfg" ;;
  esac
}

# prepare_device <arm> : dirs, core, BIOS, info, rapad, core options.
prepare_device() {
  local arm="$1" src sha_l sha_r
  src="$(core_src "$arm")" || return 1
  sh_ "mkdir -p '$DEV_DIR'/cores '$DEV_DIR'/system/dc '$DEV_DIR'/saves '$DEV_DIR'/states '$DEV_DIR'/screenshots '$DEV_DIR'/home '$DEV_DIR'/info" >/dev/null
  sha_l="$(shasum -a 256 "$src" | awk '{print $1}')"
  sha_r="$(sh_ "sha256sum '$DEV_DIR/cores/${arm}_libretro.so' 2>/dev/null; true" | awk '{print $1}')"
  if [ "$sha_l" != "$sha_r" ]; then
    adb_ push "$src" "$DEV_DIR/cores/${arm}_libretro.so" >/dev/null
    sha_r="$(sh_ "sha256sum '$DEV_DIR/cores/${arm}_libretro.so'" | awk '{print $1}')"
    [ "$sha_l" = "$sha_r" ] || { echo "core upload sha mismatch" >&2; return 1; }
  fi
  CORE_SHA="$sha_r"
  sh_ "test -f '$DEV_DIR/system/dc/dc_boot.bin' && test -f '$DEV_DIR/system/dc/dc_flash.bin' && echo ok; true" | grep -q ok || {
    adb_ push "$BENCH_HOST/bios/dc_boot.bin" "$DEV_DIR/system/dc/dc_boot.bin" >/dev/null
    adb_ push "$BENCH_HOST/bios/dc_flash.bin" "$DEV_DIR/system/dc/dc_flash.bin" >/dev/null
  }
  adb_ push "$BENCH_HOST/rapad" "$DEV_DIR/rapad" >/dev/null
  adb_ push "$BENCH_HOST/drive-loop.sh" "$DEV_DIR/drive-loop.sh" >/dev/null
  sh_ "chmod 755 '$DEV_DIR/rapad' '$DEV_DIR/drive-loop.sh'; cp -f '$INFO_DIR'/*.info '$DEV_DIR/info/' 2>/dev/null; true" >/dev/null
  # a core with options of its own as Leaf ships them: core-options-arm-<arm>.cfg
  local opts="$(profile_core_options)"
  [ -f "$BENCH_HOST/core-options-arm-$arm.cfg" ] && opts="$BENCH_HOST/core-options-arm-$arm.cfg"
  adb_ push "$opts" "$DEV_DIR/retroarch-core-options.cfg" >/dev/null
}

# write_ra_cfg <autoload 0|1>
write_ra_cfg() {
  local autoload="$1"
  # Per-profile deltas. The untouched leaf baseline emits neither
  # video_max_swapchain_images nor video_shared_context, as shipped.
  local video_threaded="false" audio_driver="pulse" max_swapchain="# video_max_swapchain_images unset (leaf profile)"
  local shared_context="# video_shared_context unset (leaf profile)" hard_sync="false"
  # Profile families: `darkos`/`dk-*` use the dArkOS RA base (threaded video,
  # alsathread, 3 swapchain images); everything else uses the leaf base.
  local ra_base="leaf" extra=""
  case "$BENCH_PROFILE" in darkos|dk-*) ra_base="darkos" ;; esac
  case "$BENCH_PROFILE" in
    g-sharedctx|dk-sharedctx) extra="sharedctx" ;;
    g-hardsync|dk-hardsync)   extra="hardsync" ;;
    g-swap2|dk-swap2)         extra="swap2" ;;
  esac
  if [ "$ra_base" = darkos ]; then
    video_threaded="true"
    audio_driver="alsathread"
    max_swapchain='video_max_swapchain_images = "3"'
  fi
  case "$extra" in
    sharedctx) shared_context='video_shared_context = "true"' ;;
    hardsync)  hard_sync="true" ;;
    swap2)     max_swapchain='video_max_swapchain_images = "2"' ;;
  esac
  sh_ "cat > '$DEV_DIR/retroarch.cfg'" <<CFG
config_save_on_exit = "false"
video_driver = "gl"
video_context_driver = "sdl_gl"
$shared_context
$max_swapchain
video_threaded = "$video_threaded"
video_hard_sync = "$hard_sync"
video_fullscreen = "true"
video_vsync = "true"
video_shader_enable = "false"
video_gpu_screenshot = "true"
fps_show = "false"
statistics_show = "false"
audio_driver = "$audio_driver"
audio_out_rate = "48000"
audio_latency = "128"
audio_sync = "true"
audio_mute_enable = "false"
input_driver = "sdl2"
input_joypad_driver = "sdl2"
network_cmd_enable = "true"
network_cmd_port = "$CMD_PORT"
network_remote_enable = "true"
network_remote_enable_user_p1 = "true"
network_remote_base_port = "$PAD_PORT"
libretro_directory = "$DEV_DIR/cores"
libretro_info_path = "$DEV_DIR/info"
core_options_path = "$DEV_DIR/retroarch-core-options.cfg"
global_core_options = "true"
system_directory = "$DEV_DIR/system"
savefile_directory = "$DEV_DIR/saves"
savestate_directory = "$DEV_DIR/states"
screenshot_directory = "$DEV_DIR/screenshots"
sort_savefiles_enable = "false"
sort_savestates_enable = "false"
sort_savefiles_by_content_enable = "false"
sort_savestates_by_content_enable = "false"
sort_screenshots_by_content_enable = "false"
savestate_auto_load = "$([ "$autoload" = 1 ] && echo true || echo false)"
savestate_auto_save = "false"
savestate_auto_index = "false"
state_slot = "0"
history_list_enable = "false"
menu_driver = "rgui"
menu_pause_libretro = "false"
pause_nonactive = "false"
quit_press_twice = "false"
stdin_cmd_enable = "false"
log_verbosity = "true"
CFG
}

# start_ra <arm> <rom> : launch detached, wait for the command port.
start_ra() {
  local arm="$1" rom="$2" i
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
exec $RA_BIN --config "$DEV_DIR/retroarch.cfg" -L "$DEV_DIR/cores/${arm}_libretro.so" "$rom" --verbose >"$DEV_DIR/retroarch.log" 2>&1 </dev/null
SH
  sh_ "chmod 755 '$DEV_DIR/launch.sh'; setsid '$DEV_DIR/launch.sh' </dev/null >/dev/null 2>&1 & exit 0" >/dev/null
  for i in $(seq 1 90); do
    sleep 0.5
    sh_ "pidof retroarch" >/dev/null || { echo "retroarch exited during startup" >&2; return 1; }
    ra_cmd "raw-request GET_PERF_INFO" | grep -q GET_PERF_INFO && return 0
  done
  echo "command port never came up" >&2
  return 1
}

stop_ra() { sh_ "pkill -x retroarch 2>/dev/null; true" >/dev/null; sleep 2; }

# screenshot <host-file> : RA's own GPU screenshot, pulled to the host.
# RA reads the frame back on the main thread but encodes/writes the PNG in a
# background task, so the file appears empty first (and stays empty for
# seconds under 3D load). Wait until its size is non-zero and stable.
screenshot() {
  local dest="$1" shot="" size prev=-1 i
  sh_ "rm -f '$DEV_DIR/screenshots/'*.png; true" >/dev/null
  ra_cmd "raw-send SCREENSHOT" >/dev/null 2>&1 || true
  for i in $(seq 1 40); do
    sleep 0.5
    shot="$(sh_ "ls -1t '$DEV_DIR/screenshots'/*.png 2>/dev/null | head -1; true")"
    [ -n "$shot" ] || continue
    size="$(sh_ "stat -c %s '$shot' 2>/dev/null || echo 0")"
    if [ "${size:-0}" -gt 0 ] && [ "$size" = "$prev" ]; then break; fi
    prev="${size:-0}"
  done
  [ -n "$shot" ] && [ "${size:-0}" -gt 0 ] || { echo "screenshot not written (empty after 20 s)" >&2; return 1; }
  adb_ pull "$shot" "$dest" >/dev/null && sh_ "rm -f '$shot'" >/dev/null
  echo "$dest"
}

# press [--hold MS] [--gap MS] TOKEN... : network gamepad (Dreamcast names)
press() { sh_ "'$DEV_DIR/rapad' $PAD_PORT $*"; }

# state_basename <rom> : RetroArch names states after the content basename.
state_basename() { local b="${1##*/}"; echo "${b%.*}"; }

# drive_start <host-script> : loop an input script on the device (background).
drive_start() {
  adb_ push "$1" "$DEV_DIR/drive.txt" >/dev/null
  sh_ "setsid '$DEV_DIR/drive-loop.sh' '$DEV_DIR/rapad' $PAD_PORT '$DEV_DIR/drive.txt' </dev/null >/dev/null 2>&1 & echo \$! > '$DEV_DIR/drive.pid'; exit 0" >/dev/null
}
drive_stop() {
  # Kill the loop's process group (setsid made it a group leader). Never use
  # pkill -f here: it matches this adb shell's own command line.
  sh_ "p=\$(cat '$DEV_DIR/drive.pid' 2>/dev/null); [ -n \"\$p\" ] && kill -TERM -- -\$p 2>/dev/null; sleep 0.3; pkill -x rapad 2>/dev/null; rm -f '$DEV_DIR/drive.pid'; true" >/dev/null
  # release everything the loop may have been holding
  sh_ "'$DEV_DIR/rapad' $PAD_PORT --hold 20 --gap 0 A+B+X+Y+START+UP+DOWN+LEFT+RIGHT+LT+RT+SL+SU 2>/dev/null; true" >/dev/null
}
