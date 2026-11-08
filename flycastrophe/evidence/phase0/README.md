# Flycastrophe Phase 0: Vulkan under Weston on the MLP1

Date: 2026-11-07. Device: MLP1 `b1622a9e81b735ad` (RK3566, kernel 5.10.209, kbase
g21p0-01eac0). Probe: `Flycastrophe-pak/tools/vkprobe` (local, unpushed), built in
mlp1-toolchain `@sha256:66aac16f…` against Khronos Vulkan-Headers v1.4.321.

## Verdict

**Outcome 2026-11-07: Vulkan not adopted; the user chose GLES in Leaf's own RetroArch.** Vulkan
works on the MLP1 with our own WSI layer and RetroArch, but with the stock core it ties GLES at
the 60 fps cap and is 1.1-2.1% slower uncapped, because the SH4 thread is the limit in both (step
4 below). Steps 5 and 6 (Leaf checklist, soak) were not run. The plan's decisions and Phase 2
table were revised for GLES (`../../flycastrophe.md`); the tooling is archived in `tools/`.

The sections below are in the order the work happened.

**Update 2026-11-07, later: step 2 passes with a pak-shipped WSI layer** (user chose option 1).
Vulkan presents through Weston on Leaf's g29p1 driver using our own build of Arm's
vulkan-wsi-layer. RetroArch build, hand run, numbers and the Leaf checklist are still to do.

First result (kept for the record): no Vulkan driver on the device can create a Wayland
surface by itself, so the gate stopped for reassessment.

**Update 2026-11-07, evening: steps 1 and 3 pass.** The pak's Vulkan RetroArch runs the card's
stock flycast core on Vulkan, fullscreen and upright, under a Leaf-mirroring `"gl"` config.
Step 4 (formal numbers) and step 5 (Leaf checklist) are still to do.

## Step 1: the pak RetroArch

Recipe: `Flycastrophe-pak/tools/retroarch/build.sh` (local, unpushed), mlp1-toolchain
`@sha256:66aac16f…`. Build info: `pak-retroarch-build-info.txt`.

- **Source:** RetroArch v1.22.2 (`69a4f0e`), then Leaf's 10-patch set vendored from
  retroarch-builds `1a72593` (`patches/retroarch/leaf/` + `SOURCE.json` with hashes; the set
  string matches Leaf `897cd1a`), then the pak's own:
  - `0001-preferred-hw-render-follows-built-driver`: `GET_PREFERRED_HW_RENDER` and the
    `SET_HW_RENDER` check answer from the driver RetroArch will really start (`video_drivers[0]`)
    when the configured one isn't built. Log: `Video driver "gl" is not built in, using "vulkan"`.
  - `0002-version-suffix`: only the `VERSION` command reply reads `1.22.2-flycastrophe`. This is
    narrower than the plan wording: changing `PACKAGE_VERSION` would also change the
    RetroAchievements user agent, menu and logs, and LEAF-RA-1 reads only the reply.
- **Configure delta from Leaf:** `--enable-wayland --disable-libdecor --disable-dbus
  --enable-vulkan --enable-slang --enable-spirv_cross --enable-builtinglslang --disable-opengl
  --disable-opengles --disable-opengles3 --disable-egl --disable-ffmpeg`, keeping
  `--disable-vulkan_display --enable-sdl2`.
  - `--enable-glslang` must stay off: forcing it makes configure demand system glslang headers
    instead of falling back to the built-in copy.
  - configure's `-lvulkan` probe is met by a stub in the throwaway container sysroot; nothing
    links it (the loader is dlopened).
  - No xkbcommon in the sysroot, so RetroArch's Wayland keyboard is off. Pads go through SDL2.
  - SDL2 comes from the rootfs (2.28.5), not a vendored copy. Leaf's two SDL patches fix SDL's
    Wayland GLES swap, which this build never uses. Decide at Phase 1 whether to vendor anyway.
- **Output:** 12.7 MB stripped, sha256 `e32307a8…`. NEEDED: SDL2, asound, freetype, pulse,
  wayland-client/cursor/egl, libstdc++, libc/libm/libgcc_s. No libvulkan, EGL or GLES.
  `--features`: SDL2, Wayland, Vulkan, glslang yes.

## Step 3: hand run

Setup: Leaf launcher paused (SIGSTOP), `tmp/dc-core-bench` harness (new `stock` arm = the
card's core `6ac785f8…`, `RA_BIN` override, `EXTRA_ENV` sourcing
`/userdata/umrk-dev/flycastrophe/env.sh`), its Leaf-mirroring `retroarch.cfg` (`video_driver
"gl"`, `video_context_driver "sdl_gl"`, pulse 48 kHz, 128 ms), `upstream-crazy-taxi.state`
auto-loaded.

| Check | Result |
| --- | --- |
| Driver choice | `gl` not built → `vulkan`; core told `RETRO_HW_CONTEXT_VULKAN`; `vulkan` cached, so `gl` stays in the config |
| Device | `Mali-G52`, API 1.3.303 (g29p1), 3 swapchain images, BGRA8888, semaphores for WSI acquire |
| Core renderer | flycast `VulkanRenderer::Init`, `VK_EXT_provoking_vertex` + `VK_KHR_buffer_device_address` on |
| Window | logs `Using resolution 720x960` from the output mode, then follows Weston's 960x720 configure: RetroArch's own screenshot is a full 960x720 frame |
| On the panel | kmsgrab of CRTC 85: game fills the 720x960 scanout, rotated the same way as the launcher's (top on the left edge), so it is upright. Patch `0003` is not needed |
| Input | Wayland input driver (forced by the context), joypads via SDL2: `Loong Gamepad` found |
| State load | auto state loaded (36.4 MB), game running |
| `dmesg` | no Mali, GPU or DRM lines; launcher resumed afterwards |

Spot check only (same state, no input, rolling 2048-frame `GET_PERF_INFO` average, one sample
set each; **not** the step 4 numbers, and the drivers differ: Vulkan on g29p1, GLES on stock g13p0):

| RetroArch | fps | frame time p95 | audio underrun | GPU load | RSS |
| --- | --- | --- | --- | --- | --- |
| Pak Vulkan | 52.8-53.3 | 19.7-19.8 ms | 19.6-20.1% | 65% @ 800 MHz | 252 MB |
| Leaf GLES | 49.3-50.5 | 20.3-20.5 ms | 19.1-19.4% | 58% @ 800 MHz | 223 MB |

## Step 4: GLES vs Vulkan numbers

Runner: `Flycastrophe-pak/tools/phase0/bench.sh` + `summarize.py` (local), on top of the
`tmp/dc-core-bench` harness: card's stock core `6ac785f8…` in both arms, Leaf-mirroring
`retroarch.cfg`, `upstream-{crazy-taxi,sa2}.state` auto-loaded, network-pad drive script looped,
CPU/GPU/DMC governors on `performance`, audio on (pulse 48 kHz, 128 ms, audio sync + vsync).
Round 0 discarded, then 3 interleaved rounds, 15 s warmup + 60 s window, SoC cooled below
58 °C between runs. fps = frame-counter deltas between 5 s samples. Raw data:
`bench-20261107/` (summary, suite log, per-run meta/samples/CPU snapshots).

Bench artifact found and removed: player 2 defaults to joypad 1, jawakad's uinput pad. With
`loong_pangu` paused, SDL's first rumble upload to it waits out the kernel's 30 s uinput timeout,
so every start took ~33 s in both arms. The runner points player 2 at index 7; startup is then
1.4 s (GLES) and 2.0-2.5 s (Vulkan). A real Leaf launch never pauses jawakad.

| Game | RetroArch | fps median | fps p5 | fps min | rep medians | frame p95 | underrun | GPU load | startup | RSS |
| --- | --- | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: |
| Crazy Taxi | GLES | 59.96 | 51.87 | 50.29 | 56.9, 60.0, 60.0 | 17.4 ms | 11.9% | 67% | 1.39 s | 277 MB |
| Crazy Taxi | Vulkan | 59.52 | 54.27 | 53.95 | 60.0, 60.0, 54.8 | 17.9 ms | 17.8% | 68% | 2.00 s | 255 MB |
| SA2 | GLES | 59.17 | 54.34 | 53.37 | 59.5, 58.8, 59.5 | 19.3 ms | 5.0% | 49% | 1.39 s | 307 MB |
| SA2 | Vulkan | 59.83 | 52.43 | 50.10 | 60.0, 59.8, 59.3 | 19.9 ms | 3.5% | 57% | 2.33 s | 268 MB |

CPU over the window, percent of one core (mean of reps):

| Game | RetroArch | RetroArch total | `Flycast-emu` | `retroarch` (main) | Mali backend | Weston | SoC busy (of 4) |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Crazy Taxi | GLES | 169 | 93 | 64 | 10 | 17 | 51% |
| Crazy Taxi | Vulkan | 159 | 95 | 54 | 7 | 17 | 49% |
| SA2 | GLES | 174 | 97 | 66 | 10 | 18 | 54% |
| SA2 | Vulkan | 155 | 97 | 49 | 7 | 19 | 49% |

Reading:

- Both RetroArchs sit at the 60 fps vsync cap most of the time; the medians compare the cap.
  The SH4 thread (`Flycast-emu`) is at 93-97% of a core in every run, so it is the limit, not
  the renderer.
- Each arm has one slow Crazy Taxi rep (GLES r1, Vulkan r3). The blind drive script diverges:
  Vulkan r3 started its window by the Ferris wheel and ended stuck against a hedge, while GLES r3
  stayed on the open street (`bench-20261107/crazy-taxi-*-r3/*.png`). The Crazy Taxi underrun
  gap (17.8 vs 11.9%) is mostly that one rep (24.0% mean in it).
- SA2's last 20 s (a heavier stretch) drop to ~53 fps in both; Vulkan dips a little lower there
  (min 50.1 vs 53.4) but holds 60 longer before it (median 59.83 vs 59.17).
- Vulkan costs 10-17 points less main-thread CPU and 2-5 points less of the SoC; RSS is
  20-40 MB lower. No Mali, GPU or DRM faults in any of the 16 runs.

**Strict gate reading (step 6 numbers):** not met. Crazy Taxi: median fps 59.52 vs 59.96, frame
p95 17.9 vs 17.4 ms, underruns 17.8 vs 11.9%. SA2: frame p95 19.9 vs 19.3 ms (median fps and
underruns pass). Startup passes on both (within +1 s). Every miss is smaller than the
rep-to-rep spread of either arm, so these numbers show a tie at the cap rather than a slower
Vulkan, but the gate as written asks for "no worse".

### Uncapped (user asked for it after the capped run)

Same runner with `UNCAPPED=1 DRIVE=0`: `video_vsync` and `audio_sync` set to `false` in place,
no input (the state plays itself, so both arms see the same scene), round 0 discarded, 3
interleaved rounds, 10 s warmup + 30 s window. Raw data: `bench-20261107-uncapped/`.

| Game | RetroArch | fps median | fps p5 | rep medians | frame p95 | GPU load | startup |
| --- | --- | ---: | ---: | --- | ---: | ---: | ---: |
| Crazy Taxi | GLES | 58.85 | 57.79 | 58.8, 59.3, 58.8 | 18.2 ms | 53% | 1.12 s |
| Crazy Taxi | Vulkan | 58.19 | 57.10 | 58.0, 58.1, 58.6 | 18.0 ms | 54% | 1.77 s |
| SA2 | GLES | 62.04 | 60.43 | 62.8, 62.0, 60.8 | 17.2 ms | 43% | 1.13 s |
| SA2 | Vulkan | 60.77 | 59.78 | 61.2, 60.5, 60.7 | 17.2 ms | 52% | 2.06 s |

| Game | RetroArch | RetroArch total | `Flycast-emu` | `retroarch` (main) | Mali backend | Weston | SoC busy (of 4) |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Crazy Taxi | GLES | 204 | 98 | 94 | 10 | 18 | 61% |
| Crazy Taxi | Vulkan | 174 | 99 | 65 | 8 | 19 | 54% |
| SA2 | GLES | 185 | 100 | 73 | 11 | 18 | 56% |
| SA2 | Vulkan | 164 | 99 | 55 | 8 | 20 | 51% |

Reading:

- Uncapped, the stock core reaches only 58-62 fps, with `Flycast-emu` at 98-100% of a core in
  every run: the SH4 thread is the ceiling, and the renderer is not.
- **Vulkan is 1.1% (Crazy Taxi) and 2.1% (SA2) slower in median throughput**, consistently: every
  Vulkan rep is below the GLES median except one SA2 rep. The screenshots agree: same SA2 scene,
  and the in-game timer ends 0.48 game-seconds behind GLES over the window.
  (`bench-20261107-uncapped/sa2-*-r1/end.png`).
- Since the emu thread is saturated in both, the 1-2% is most likely work the stock core's Vulkan
  path leaves on that thread (TA processing, texture conversion) rather than presentation cost.
  Not profiled.
- Vulkan still costs 21-29 points less of RetroArch's main thread and 5-7 points less of the
  SoC. That headroom only turns into frames once the emu thread stops being the limit, or once
  more threads compete for the 4 cores (Deadcast's AICA, TA parse and upload threads).
- No faults in any of the 16 runs.

**Verdict on the numbers:** with the stock core, Vulkan is not faster than GLES and is 1-2% slower
on raw throughput. By decision 2 ("Vulkan slower than GLES → stop and reassess"), the gate is
not met; this goes back to the user with the numbers.

Points for step 5: RetroArch logs `Couldn't find any video driver named "gl"` at every start
(expected, it falls back); confirm on a real Leaf launch that the cached-driver restore keeps
`video_driver "gl"` in the saved config, and how Leaf's input proxy pad behaves through the
Wayland input driver.

## Step 2 with the Flycastrophe WSI layer

Recipe: `Flycastrophe-pak/tools/wsi-layer/build.sh` (local, unpushed), following ROCKNIX's
RK3566 package. Source `ginkage/vulkan-wsi-layer@40cfec09`, Khronos Vulkan-Headers v1.4.356
(the layer's validated version), mlp1-toolchain image, `BUILD_WSI_WAYLAND=ON`, headless /
display / X11 off, `dma_buf_heaps` on heap `system`, FIFO presentation thread on.

- **Build fixes:** the fork includes `<xcb/xcb.h>` and `<X11/Xlib.h>` unconditionally in
  `layer/private_data.hpp`; the sysroot has neither, so `tools/wsi-layer/stub-include/`
  supplies the four handle typedefs (`-idirafter`). No source patch.
- **Output:** `libVkLayer_window_system_integration.so` (252 KB stripped; NEEDED: wayland-client,
  libstdc++, libm, libgcc_s, libc) plus a manifest renamed to `VK_LAYER_flycastrophe_wsi`.
- **Must be implicit.** Loader 1.3.207 lists an explicitly enabled layer's instance
  extensions only when asked by layer name, and RetroArch checks the unnamed list for
  `VK_KHR_wayland_surface`. The manifest therefore sits in `<dir>/vulkan/implicit_layer.d/`, is
  found through `XDG_DATA_DIRS=<dir>:…`, and only turns on with `FLYCASTROPHE_WSI=1` (off
  switch `DISABLE_FLYCASTROPHE_WSI=1`). The system layer is switched off with `DISABLE_WSI_LAYER=1`.
- **Needs g29p1.** The layer's Wayland backend requires `VK_KHR_calibrated_timestamps`. Stock
  g13p0 has only the EXT version, and Leaf's g29p1 has both (selected with `VK_ICD_FILENAMES`
  + `LD_LIBRARY_PATH` into `runtime/graphics/vulkan/rk3566-g52-g29p1`).

Environment used (`/tmp/fcr/env.sh` on the device):

```sh
R=/mnt/sdcard/.system/leaf/platforms/mlp1/runtime/graphics/vulkan/rk3566-g52-g29p1
export XDG_RUNTIME_DIR=/var/run WAYLAND_DISPLAY=wayland-0
export XDG_DATA_DIRS=/tmp/fcr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}
export DISABLE_WSI_LAYER=1 FLYCASTROPHE_WSI=1
export VK_ICD_FILENAMES=$R/share/vulkan/icd.d/rk_vk_g29.json LD_LIBRARY_PATH=$R/lib
```

Results (`vkprobe-g29p1-with-flycastrophe-wsi-layer.txt`):

| Check | Result |
| --- | --- |
| `VK_KHR_wayland_surface`, presentation support, surface support | yes, yes, yes |
| xdg_toplevel configure | 960x720 (Weston rotates the 720x960 panel; no pre-rotation needed) |
| Surface caps | 2-6 images, extent chosen by the app, transform identity, usage 0x9f |
| Present modes | fifo, mailbox, immediate, shared |
| FIFO, 600 frames, 3 × 960x720 BGRA | 59.19-59.46 fps (panel 60.038 Hz), gaps 10.6-21.6 ms, 3 over 20 ms |
| FIFO, 1,200 frames, kmsgrab at 5 s | 59.68 fps, worst 33 ms, 7 over 20 ms |
| Mailbox / immediate, 600 frames (clear only) | ~1,030-1,056 fps, worst 7.4 ms |
| kmsgrab of CRTC 85 mid-run | every pixel is the probe's cycling color: fullscreen and on the panel |
| `dmesg` | no new Mali, GPU or DRM lines |

Open points this does not settle: whether the pak should ship its own g29p1 (60 MB, Arm EULA)
or point at Leaf's runtime copy; patching the layer to accept the EXT calibrated-timestamps
extension so stock g13p0 also works; the `system` vs `system-uncached` heap.

| Stack | Device API | `VK_KHR_wayland_surface` | Surfaces offered |
| --- | --- | --- | --- |
| Stock g13p0 (`/usr/lib/libmali.so.1.9.0`) + system WSI layer | 1.2.218 | no | `VK_KHR_display`, `VK_EXT_headless_surface` |
| Stock g13p0, `DISABLE_WSI_LAYER=1` | 1.2.218 | no | same |
| Leaf g29p1 (`runtime/graphics/vulkan/rk3566-g52-g29p1`) + system WSI layer | 1.3.303 | no | same |
| Leaf g29p1, `DISABLE_WSI_LAYER=1` | 1.3.303 | no | same |

- Loader: Khronos `libvulkan.so.1.3.207` (a `1.3.214` file also sits in `/usr/lib`, unused).
- ICD manifest `/usr/share/vulkan/icd.d/rk_vk.json` → `/usr/lib/libmali.so`, `api_version 1.0.5`
  (the manifest understates; the device reports 1.2.218).
- System implicit layer `VK_LAYER_window_system_integration`
  (`/lib/libVkLayer_window_system_integration.so`, api 1.3.216) advertises only
  `VK_EXT_headless_surface`, `VK_KHR_surface`, `VK_KHR_get_surface_capabilities2`: it was built
  without its Wayland backend. Disable switch: `DISABLE_WSI_LAYER=1`.

## Facts for the reassessment

What a self-built Wayland WSI layer would need is present:

- **Driver (stock g13p0) device extensions:** `VK_EXT_image_drm_format_modifier`,
  `VK_EXT_external_memory_dma_buf`, `VK_KHR_external_memory_fd`, `VK_KHR_external_fence_fd`,
  `VK_KHR_external_semaphore_fd`, `VK_EXT_queue_family_foreign`, `VK_KHR_image_format_list`,
  `VK_KHR_bind_memory2`, `VK_KHR_dedicated_allocation`, `VK_KHR_timeline_semaphore`.
- **Weston 13.0.1 globals:** `zwp_linux_dmabuf_v1` v3, `zwp_linux_explicit_synchronization_v1`
  v2, `wp_presentation` v1, `wp_viewporter`, `wp_tearing_control_manager_v1`, `xdg_wm_base` v5,
  `mali_buffer_sharing` v5, `weston_direct_display_v1`.
- **Output:** DSI 720x960 @ 60.038 Hz, `transform 1` (Weston rotates; clients see 960x720).

Other device facts the later phases need:

- One 1024 MB heap; memory types `0x7`, `0xb`, `0x11` (`LAZILY_ALLOCATED` present, so
  Deadcast's lazy depth buffers have a real memory type).
- One queue family (graphics/compute/transfer, 2 queues, 64-bit timestamps,
  `timestampPeriod` 41.667 ns).
- `vm.max_map_count` 65530; `VmallocTotal` 263061440 kB; 955 MB RAM, ~727 MB available idle.
- The arm64 kernel gives userspace a 39-bit or larger VA (VmallocTotal ≈ 251 GB), enough for the
  4 GB window; the 16-window MMU work (~68 GB) needs checking against the real VA split.

## Options

1. **Ship ARM's open-source `vulkan-wsi-layer` with its Wayland backend in the pak.** The pak
   wrapper disables the system layer (`DISABLE_WSI_LAYER=1`) and loads its own (`VK_LAYER_PATH`
   and `VK_INSTANCE_LAYERS`, both allowed "graphics driver selection"). Every extension and
   protocol it needs is listed above. Unknowns: whether Weston imports the Mali buffers'
   modifiers, present pacing, how the layer behaves on loader 1.3.207. A bounded
   experiment: build the layer, then rerun `vkprobe --present 600`.
2. **GLES:** put the core in Leaf's own RetroArch and port only the CPU, audio and thread work.
3. **Direct DRM:** a platform plan letting content-pak frontends stop Weston. That means a
   contract change plus Jawaka work, and Flycastrophe waits for it.
4. **Stop the project.**

## Files

- `vulkan-icd-and-layer-manifests.txt`: ICD and implicit layer JSON from the device.
- `vkprobe-g13p0-stock.txt`: full probe output on the stock driver, including device extensions.
- `vkprobe-g29p1-and-weston-globals.txt`: probe on Leaf's g29p1, then the compositor globals.
- `vkprobe-g29p1-with-flycastrophe-wsi-layer.txt`: probe and present runs through our layer.
- `pak-retroarch-build-info.txt`: commit, toolchain, configure line, NEEDED, sha256.
- `hand-run-vk-crazy-taxi-retroarch.log`, `hand-run-gles-crazy-taxi-retroarch.log`: full
  RetroArch logs of the two hand runs.
- `hand-run-vk-crazy-taxi-scanout.png` (panel scanout), `hand-run-vk-crazy-taxi-ra-screenshot.png`
  (RetroArch's own), `hand-run-launcher-scanout-reference.png` (launcher, for the rotation check).
- `bench-20261107/`: step 4 summary, suite log, and per run `meta.txt`, `samples.txt`, CPU
  snapshots; screenshots for the Crazy Taxi r3 route divergence; two RetroArch logs.
- `bench-20261107-uncapped/`: the uncapped, no-input run, same layout, SA2 r1 end frames.
