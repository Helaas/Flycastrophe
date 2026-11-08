# Flycastrophe: Flycast libretro core with Deadcast speed patches (MLP1, Pak Rat)

Moved from the UMRK workspace (`plans/flycastrophe.md`) on 2026-11-08; the evidence it links to
is in [evidence/](evidence/), the scripts in [bench/](bench/README.md).

> **Status 2026-11-07:** Phase 0 (the Vulkan gate) is done and Vulkan is **not** adopted. On
> the MLP1, the stock flycast core under a pak-shipped Vulkan RetroArch was a tie with Leaf's
> GLES RetroArch at the 60 fps cap and 1.1-2.1% slower uncapped; the SH4 emulator thread is the
> limit in both. By decision 2 the user reassessed and chose **GLES in Leaf's own RetroArch**.
> Phase 0 results and why: [Phase 0 outcome](#phase-0-outcome-vulkan-gate-done) below and
> [evidence/phase0/README.md](evidence/phase0/README.md).
> Phase 1 started 2026-11-07: `Helaas/Flycastrophe` forked (default branch `main` at `7adbf3c`,
> upstream workflows disabled). PR 00 is Helaas/Flycastrophe#1; `fcr-base` matches the stock core
> uncapped (+1.4% Crazy Taxi, +3.9% SA2; `evidence/phase1/`). `Flycastrophe-pak` is
> committed locally (`main` + `agent/initial-pak`, `make check` passes from the pinned commit); its
> public GitHub repo waits on the user's OK.
> Later the same day: both repos public; PR 00, the pak (`33eae8f`, core hash reproduced in CI) and
> PR 02 (texture DMA) merged; PR 03 (AICA thread) measured +5.9% Crazy Taxi / +19.0% SA2 uncapped.
> CHD read-ahead back to pending. Bench method: still scenes primary (see Verification).
> 2026-11-08: fork `main` at `6c5e49a`. Merged since: TA parse thread (#4), 28-byte vertex (#5),
> Deadcast's dynarec unit (#6), the AICA thread stopped on unload (#7, fixed RetroArch aborting at
> exit), unchanged textures not re-uploaded (#8, neutral), sorting changes + Daytona EU (#9), code
> cache on disk (#10), lag-based frame skip adapted to RetroArch's pacing (#11, default Maximum).
> Still scenes vs `fcr-main`: Crazy Taxi ~59.9 → ~71 fps, SA2 ~62.3 → ~91 fps. Later 2026-11-08:
> GD-ROM read lock (#12, a missed part of the AICA thread), perf line `FLYCASTROPHE_PERF=1` (#13);
> CHD read-ahead skipped (reads under 1% of a thread). Deadcast reviewed through `b24817b`; the
> ledger has no pending rows. Main at `115dd9d`; the pak (Helaas/Flycastrophe-pak#2, `020ce56`) pins it,
> core sha256 `4a22ad60…` from two clean local builds and CI. Pak Rat device pass done the same day
> (install, reinstall, pickers, uninstall, recovery; left installed from a local feed). Next: hands-on play,
> then a release only on the user's go. Plan, evidence and bench moved into this repository's `flycastrophe/`.
> Release bar run 2026-11-08 ([phase3](evidence/phase3/README.md)): with audio on,
> Flycastrophe holds 60 fps on both games with the lowest frame-time p95 (Leaf's Flycast 58.5/59.9,
> FlyCast Fast UMRK 35.0/58.2); uncapped Crazy Taxi 71.6 vs 58.9 vs 48.5 (same scene), SA2 91.4 vs
> 61.4 vs Leaf's Flycast (FlyCast Fast UMRK's 2022 state is another scene; the 2026 cores refuse
> 2022 states). Boot checklist: all 17 games boot and exit cleanly; hands-on play still to do. Results:
> [evidence/phase2/README.md](evidence/phase2/README.md).

## Context

clintor's Deadcast (`tyrannotorus/emulator-dreamcast-deadcast`) makes Flycast fast on the
TrimUI Brick by trading accuracy and portability for speed. It is a standalone, Vulkan-only,
Brick-only program, plus an unrelated per-game recomp system. We want those speedups in a
clean Flycast **libretro core** for the MLP1, shipped through Pak Rat, under the **Helaas**
GitHub account (not the UMRK org). The name owns the jank.

Facts that shape the plan:
- Upstream `flyinghead/flycast` master `7adbf3c` (2026-10-31) is Deadcast's base `1b63c8a`
  plus one translations commit. Deadcast has no shared git history (squashed root
  `3e3b549579`) but its tree matches `1b63c8a` in 3,138 files, so it diffs cleanly file by file.
  Deadcast does not touch serialization, so states should cross with upstream.
- Deadcast deleted the libretro frontend and every GL renderer. Its Brick presenter
  (`core/rend/vulkan/panel.cpp`, fb0 dma-buf, DSI register poke) is unusable here.
- Leaf's MLP1 RetroArch is GLES3-only, and Leaf writes `video_driver "gl"` /
  `video_context_driver "sdl_gl"` into every runtime.cfg (`Jawaka/internal/platform/paths.c:2855`).
- Phase 0 measured the stock core (c3763d8, sha `6ac785f8…`) at 58-62 fps uncapped on Crazy Taxi
  and SA2, with `Flycast-emu` (the SH4 thread) at 98-100% of a core and RetroArch's main thread
  at 64-66% of a core at 60 fps on GLES. **The SH4 thread is what Flycastrophe has to speed up.**
- Leaf already ships `flycast_fast_umrk` (flycast 2022 + PGO + A55 tuning). Flycastrophe is the
  fourth DC choice and has to beat it.

## Decisions

Settled in the grill on 2026-11-07; 1, 3, 7, 10 and 11 revised the same day after Phase 0.

1. **GLES3 in Leaf's own RetroArch.** A content pak whose `cores[]` entry has no `frontend`:
   Leaf's RetroArch loads `flycastrophe_libretro.so` like any other core. *(Was: Vulkan through
   a pak-local RetroArch. Dropped after Phase 0, see below.)*
2. **Phase 0 was a hard gate.** It triggered (Vulkan slower uncapped) and the user chose GLES.
3. **No RetroArch in the pak.** *(Was: vendored Leaf RetroArch built with Vulkan.)*
4. **Two repos under Helaas:** `Helaas/Flycastrophe` (GitHub fork of flyinghead/flycast) and
   `Helaas/Flycastrophe-pak` (builds the core from the pinned fork commit, packages it,
   release workflow). Like ScummVM-pak, it builds from a clean clone with no sibling checkout.
5. **Sync: merge + port ledger.** Fork default branch `main`; upstream synced by merging
   `upstream/master` via PR, no force-push. One commit per Deadcast port, naming the Deadcast
   SHA. `FLYCASTROPHE.md` records the last Deadcast SHA reviewed and every change as
   ported / adapted / skipped / pending with the reason.
6. **Accuracy hacks as core options, default on:** `reicast_fcr_fast_fipr` (NEON fipr/ftrv),
   `reicast_fcr_threaded_audio` (AICA thread), `reicast_fcr_idle_loop_skip`.
7. **28-byte vertex baked in, adapted to GLES.** The core builds GLES3 only: Vulkan and the GL4
   per-pixel renderer (`HAVE_OIT`) are compiled out in CMake (their files stay, so merges stay
   clean). The per-pixel sorting option goes. Naomi 2 normals move to their own GL buffer
   (see [Vertex format on GLES](#vertex-format-on-gles)). Nothing visible is lost from the
   two-volume drop: the GLES renderer never drew the second volume.
8. **Systems: DC + NAOMI + ATOMISWAVE** via three `system_extensions`; arcade marked experimental.
9. **Own VMU folder:** `getVmuPath` → `BIOS/dc/flycastrophe/vmu_save_<port>.bin`.
10. **Shaders work** as for any core in Leaf's RetroArch. *(Was: none in v0.1, a Vulkan limit.)*
11. **No settings isolation needed.** Same RetroArch as Leaf; per-core options, remaps and
    overrides live under the core's own "Flycastrophe" folder. *(Was: a `VERSION` suffix.)*
12. **Release bar:** faster than stock `flycast` and `flycast_fast_umrk` on the Crazy Taxi + SA2
    bench (audio on), all three in Leaf's RetroArch, and the play checklist passes or is
    documented broken.
13. **Build:** `-mcpu=cortex-a55`, LTO; PGO only if the bar is missed without it.

Defaults (change at review if wanted): core id / `libretro_name` `flycastrophe`; `display_name`,
`config_folder`, `library_name`, `.info` corename "Flycastrophe"; info file
`flycastrophe_libretro.info` (`required_hw_api "OpenGL ES >= 3.0"`); store id
`org.helaas.flycastrophe`, author "Helaas", `content[]` lane, install name `Flycastrophe.pak`;
pak version `0.1.0`; `min_leaf_version` `0.14.0` (current stable). Option prefix stays
`reicast_`. Avoid reserved names: `flycast`, `flycast_fast_umrk`, `flycast_standalone`,
`km_flycast_xtreme`, `flycast_standalone_pak`, `org.umrk.flycast`, `Flycast.pak`.

## Phase 0 outcome (Vulkan gate, done)

Full record: [evidence/phase0/README.md](evidence/phase0/README.md),
raw runs in `bench-20261107/` and `bench-20261107-uncapped/` beside it.

1. **No Mali Vulkan stack on the MLP1 offers `VK_KHR_wayland_surface`.** The system WSI layer is
   built without Wayland. Our own build of Arm's vulkan-wsi-layer (ginkage `40cfec09`, ROCKNIX
   recipe) fixed that on Leaf's g29p1 driver only (it needs `VK_KHR_calibrated_timestamps`), as
   an implicit layer found through `XDG_DATA_DIRS`: FIFO ~59.5 fps fullscreen, no faults.
2. **A Vulkan RetroArch** (v1.22.2 + Leaf's 10 patches + 2 pak patches, Wayland + Vulkan, no GL)
   ran the stock core on Vulkan under Leaf's `"gl"` config: upright, fullscreen, no faults.
3. **Capped bench** (3 rounds, 60 s, drive script, audio on): a tie at 60 fps; the strict
   "no worse" checks missed by less than rep noise. Vulkan used 10-17 points less of
   RetroArch's main thread.
4. **Uncapped bench** (vsync and audio sync off, no input, 3 rounds): Vulkan **1.1% (Crazy Taxi)
   and 2.1% (SA2) slower**, consistently; `Flycast-emu` at 98-100% of a core in both.

Why GLES: the SH4 thread is the limit, so Deadcast's Vulkan renderer work (which unloads the
render thread and GPU) would not add frames here, while most of its SH4-thread work is renderer
neutral. GLES drops the pak RetroArch, the WSI layer, the dependency on Leaf's g29p1 driver,
the Wayland and HDMI unknowns, and the settings isolation, and keeps shaders.

The Phase 0 tooling (vkprobe, WSI layer build, Vulkan RetroArch build, its two patches, the
bench runner) is archived in `evidence/phase0/tools/`. The live bench runner moved
next to the harness it drives: `tmp/dc-core-bench/flycastrophe/bench.sh` (arms `gles` = Leaf's
RetroArch + stock core, `vk`, and `fcr-<name>` = Leaf's RetroArch + `out/fcr-<name>_libretro.so`;
the first arm is the baseline).

## Phase 1: repos and baseline

- `gh repo fork flyinghead/flycast --fork-name Flycastrophe` under Helaas; clone to
  `/Volumes/Storage/UMRK/Flycastrophe`; default branch `main` at `7adbf3c`; remotes `upstream`
  and `deadcast`. Disable upstream's workflows on the fork (`gh workflow disable`); add a new
  `.github/workflows/flycastrophe-mlp1.yml` (no upstream file edited).
- **PR 00 Bootstrap** on the fork:
  - `FLYCASTROPHE.md` ledger ("Deadcast reviewed through `82b57f2571`"), including the
    [Deadcast changes the GLES path does not use](#deadcast-changes-the-gles-path-does-not-use).
  - CMake: OUTPUT_NAME `flycastrophe_libretro`; `-DLIBRETRO=ON -DUSE_GLES=ON -DUSE_VULKAN=OFF
    -DUSE_OPENMP=OFF -DUSE_HOST_LIBZIP=OFF`, IPO on, `-mcpu=cortex-a55`. A `FLYCASTROPHE`
    option skips `add_subdirectory(gl4)` and the `HAVE_OIT` define; `Renderer_if.cpp`'s
    `OpenGL_OIT` case is guarded on `HAVE_OIT`.
  - `shell/libretro/libretro.cpp`: `library_name "Flycastrophe"`. `libretro_core_options.h`:
    drop per-pixel.
  - `shell/libretro/oslib.cpp`: VMU path (decision 9).
  - The `.info` file lives in the pak repo (`info/flycastrophe_libretro.info`), not the fork.
  - `.github/workflows/flycastrophe-mlp1.yml`: MLP1 cross-build only (NEEDED and library-name
    checks); the x86-64 unit tests were dropped for speed (user, 2026-11-07: MLP1 is the only
    target). A GLES libretro build needs only the `asio`,
    `libchdr`, `rcheevos` and `tinygettext` (+ its `tinycmmc`) submodules.
  - Result `fcr-base` must match stock c3763d8 speed in Leaf's RetroArch (bench runner, arms
    `stock` vs `fcr-base`).
- Pak repo `Helaas/Flycastrophe-pak`, ScummVM-pak / J2ME-pak shape: `upstream.lock.json` (fork
  commit, toolchain digest, `source_date_epoch`), `pak/pak.json` (`cores[]`, three
  `system_extensions`, no `frontend`), `scripts/` (fetch, build in the toolchain image,
  validate), `tests/`, `.github/workflows/{ci,release}.yml`, `LICENSES/` (GPL-2.0), README
  crediting flyinghead and tyrannotorus. Package: `cores/flycastrophe_libretro.so`,
  `info/flycastrophe_libretro.info`. The local skeleton's Vulkan tooling (`tools/retroarch`,
  `tools/wsi-layer`, `tools/vkprobe`, `patches/retroarch`) does not go into it.

## Phase 2: Deadcast ports (one topic PR each on the fork)

Every PR: commits name the Deadcast SHA; Deadcast paths (`core/deadcast/*`) kept verbatim;
Flycastrophe glue in `shell/libretro/` and `core/flycastrophe/`; A/B bench against the previous
fork head (3 interleaved rounds, audio on, plus the uncapped no-input arm; screenshot gate);
ledger row updated. A topic that regresses or breaks the checklist is recorded as skipped and
not merged.

| PR | Topic | Deadcast source | Option / switch | On GLES | Risk |
| --- | --- | --- | --- | --- | --- |
| 01 | Perf counters (`FLYCASTROPHE_PERF=1`) | `3e3b549579` profiler, `110019952a`, `12fe9e85fe`, `117a12188d`, `055a8c6701`, `6c0c3f68a6` | env | Core counters only; the Vulkan renderer's counters don't apply | Low |
| 02 | CHD read-ahead, texture DMA unprotect | `3e3b549579` chd.cpp, `9cda9c4082` | none | As is | Low |
| 03 | AICA thread (netplay journal stripped) | `3e3b549579`, `3299519ff9`, AICA half of `d1be34d557` | `reicast_fcr_threaded_audio` | As is | Medium |
| 04 | 4 GB memory window + fault rewrite | `3e3b549579` addrspace/posix_vmem/virtmem/sh4_mmr | none | As is | Medium |
| 05 | Pinned-register dynarec, thunks, inline IRQ, SQ→TA direct | `3e3b549579`, `d1be34d557`, `f42955105f` | env `FLYCASTROPHE_NO_PIN` | As is | High |
| 06 | NEON fipr/ftrv | `3e3b549579` rec_arm64 | `reicast_fcr_fast_fipr` | As is | Low-med |
| 07 | Idle-loop skips | `3e3b549579`, `b1b0cb1744` waitloops | `reicast_fcr_idle_loop_skip` | As is | Low |
| 08 | 28-byte vertex, Naomi 2 normals | `3e3b549579` ta_ctx.h, ta_vtx.cpp, elan.cpp, sorter.cpp | none | **Adapted**: core part as is, GL glue new (below) | Medium |
| 09 | TA parse thread | `3e3b549579` Renderer_if.cpp, ta_ctx.cpp | env | As is; check texture fetch stays on RetroArch's GL thread | Medium |
| 10 | Unchanged textures not re-uploaded (data hash at last upload) | `3e3b549579` TexCache, `ff68543516` | none | The shared `TexCache` part only; the upload worker is skipped | Low-med |
| 11 | Frameskip on lag + audio fill via `SET_AUDIO_BUFFER_STATUS_CALLBACK` | `f212a71804`, `1b8db315e8` | `reicast_auto_skip_frame` | As is; check the "busy renderer" wait against GL | Medium |
| 12 | Sorting heuristics, Daytona exception, fast GD-ROM load default | `3e3b549579` ta_util, `564410027b`, `a7ed1b550b` | default change | As is | Low |
| 13 | MMU windows, versioned block cache (WinCE) | `3e3b549579` mmuwindows, `a7ed1b550b` | none | As is | High |
| 14 | Code cache to `Saves/Flycastrophe/<content>.blocks` | `9909d48688`, `f42955105f` | env | As is | Medium |
| 15 | Optional: PGO, only if the bar is missed | none | none | | Medium |

### Vertex format on GLES

Deadcast's `Vertex` keeps position, base color, offset color and UV (28 bytes, was 56); the
second volume of two-volume polygons is dropped and Naomi 2 normals move to
`rend_context::normals`, indexed like `verts`. Half the bytes per vertex for the SH4 thread to
write in TA parsing, and half the vertex upload.

Work, about **one day**, in PR 08:

- **Core, ported as is (~100 changed lines):** `ta_ctx.h` (`Vertex`, `N2Vertex`, `VertexNormal`,
  `normals`), `ta_vtx.cpp` (second-volume writes gone, `ta_add_vertex(const N2Vertex&)` fills
  `normals`), `elan.cpp` (builds `N2Vertex`), `sorter.cpp` (2 lines).
- **GL glue, new (~40-60 lines):** the GLES renderer already reads only position, colors, UV
  and the normal; the first four keep their `offsetof` and pick up the 28-byte stride by
  themselves. The normal moves to a second `GlBuffer` (`gles.h`, created and freed in
  `gles.cpp`, uploaded next to `verts` at `gles.cpp:1243`, padded to `verts.size()` because
  `normals` stops at the last Naomi 2 vertex). `MainVertexArray::defineVtxAttribs`
  (`gldraw.cpp:473`) points `VERTEX_NORM_ARRAY` at that buffer with a 12-byte stride, and the
  attribute is switched off for frames without Naomi 2 geometry. The GL4 renderer, the only GL
  reader of the second volume, is already out (PR 00).
- **Testing (half of the day):** Dreamcast frames must match the PR 07 head exactly (GLES never
  drew the second volume); a Naomi 2 game for lighting: not on the test card, but the user's
  library has VF4 (+ Evolution, Final Tuned), Beach Spikers and Virtua Striker 3 in
  `/Volumes/home/Roms/naomi2.zip`; A/B bench.

### Deadcast changes the GLES path does not use

Recorded as "skipped" in the ledger, with the reason. Renderer work, all Vulkan-only:

- **GpuAllocator** replacing VMA (`allocator.cpp/h`, replaces `vmallocator.*`; buffer and
  texture allocation through it). Was PR 10.
- **Precompiled SPIR-V + specialization constants** (`vulkan/shaders/`, replaces the runtime
  `compiler.cpp`). Was PR 11.
- **Descriptor cache, bind skipping, batched modifier volumes, lazy (transient) depth
  buffers** (`drawer`, `pipeline`, `commandpool`), and the Vulkan GPU timer (`gputimer.h`). Was
  PR 12.
- **Texture upload worker** (`ff68543516`): decoding into Vulkan staging memory and copying the
  frame's vertices on a worker thread. It hangs off `UploadToGPUBegin`, which defaults to "not
  supported", so GL simply uploads as before. A GL version (decode into a mapped pixel buffer
  object on the worker, `glTexSubImage2D` on RetroArch's thread) would be new work, not a port.
  Was the worker half of PR 13.
- **Handing the renderer's image straight to RetroArch** (Vulkan). Was half of PR 18.
- **Vulkan renderer perf counters** in PR 01's commits.
- The Vulkan per-pixel (OIT) renderer was already dropped in the Vulkan plan; on GLES the GL4
  per-pixel renderer goes the same way (decision 7).

Already skipped before the switch (unchanged): recomp, `ui/`, store, menu,
`linux-dist/main.cpp`, `shell/brick/*`, SDL audio backend (`b7537ce331`, `399d2f674f`),
netplay/link (`395653a2a1`, `821fd559d8`, `8e68988667`), forced NTSC/VGA, `panel.cpp`, DSI poke
(`f8e4afe003`), `fc84aa2d87`, `56d273596c`, `82b57f2571`. Deadcast commits after the review point
(`9ffccd7c7f` frame skip always on, `b5854cb951` Options pages) are "pending" in the ledger.

## Phase 3: release

1. Pak repo pins the fork head that met the bar; CI builds the ZIP; device pass through Pak Rat
   with `jawaka-pakrat-smoke install` from a local feed via `adb reverse` (never hand-stage over
   Pak Rat; remove dev-catalog-url afterwards).
2. Release bar run (below). Results and known-broken games go in the README.
3. **With the user's explicit go only:** tag `v0.1.0`, the release workflow makes a draft
   (ZIP, GPL corresponding source, SHA256SUMS), verify CI ZIP is byte-identical to the tested
   one, publish.
4. leaf-docs PR: `content[]` entry in `public/pakrat/v1/storefront.json` (versions[] gated
   0.14.0) + guide page `src/content/docs/app-store/flycastrophe.md` following
   `docs/writing-style.md`.

Bookkeeping: add both repos to the AGENTS.md repo map (owner Helaas); commits without AI
attribution; branches `agent/<slug>`; PRs with self-merge on green CI.

## Verification

- **Per PR:** MLP1 build in CI (the only CI job); A/B on device with
  `tmp/dc-core-bench/flycastrophe/bench.sh` (arms `fcr-main fcr-<pr>`). Primary: still scenes,
  uncapped (`UNCAPPED=1 DRIVE=0`, 1 round quick / 2 rounds to merge; spread ~0.5-2%, so changes
  under ~2% don't show). Moving replays (`REPLAY=1`, `record-replay.sh`) diverge between runs
  under threaded rendering, so they are a secondary signal only; capped runs only for pacing or
  audio PRs. Method and results: `evidence/phase2/README.md`.
- **Release bar:** Flycastrophe vs stock `flycast` vs `flycast_fast_umrk`, all in Leaf's
  RetroArch, Crazy Taxi + SA2, 3 interleaved rounds. Play checklist with 10 minutes each: Sega
  Rally 2 (WinCE/MMU), DOA2, Daytona 2001, MvC2, Shenmue, Skies of Arcadia, Rez, Power Stone,
  Crazy Taxi, SA2; NAOMI capsnk + ggxx; Atomiswave dolphin + fotns + mslug6 (on the test card);
  one Naomi 2 game (VF4 from `/Volumes/home/Roms/naomi2.zip`). For each: boots, plays, state round trip, VMU lands
  in `BIOS/dc/flycastrophe/`, each hack option toggles.
- **Leaf lifecycle** with the real pak installed through Pak Rat: in-game menu, slot save/load
  with thumbnails, power-hold save, boot resume, Game Switcher 10x (RSS steady), m3u disc swap,
  SIGTERM flushes VMU within 2 s, a GLSL shader applies.
- **Catalog:** leaf-docs `pakrat-catalog.yml` (`validate-pakrat-catalog.mjs --remote`) green.

## Top risks

1. Dynarec port correctness (pinning, x18, clang→GCC 12.3); MMU windows' ~68 GB VA and
   `max_map_count`; releasing reservations on same-core reloads.
2. Thread oversubscription on 4 cores (SH4, RetroArch's GL thread at ~65% of a core, AICA,
   parse, CHD + Weston, Pulse); every threaded feature keeps an off switch. GLES leaves less
   room here than Vulkan would have (10-17 points of a core in Phase 0).
3. Savestate timing: parse/AICA threads quiesced in `retro_serialize`; code-cache warm inside
   LOAD_STATE_SYNC's 10 s; save inside SIGTERM's 2 s grace.
4. TA parse thread and frameskip were written against Deadcast's Vulkan renderer; their
   handshakes with the renderer have to be re-checked against the GL renderer.
5. Naomi 2 normals path: test with VF4 / Beach Spikers from `/Volumes/home/Roms/naomi2.zip`
   (copy to the card's `Roms/NAOMI` with the Naomi 2 BIOS).
6. Deadcast drift: daily squash-free commits arrive as file diffs; the ledger is the only record.
