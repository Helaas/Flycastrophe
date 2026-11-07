# Flycastrophe

Flycastrophe is [Flycast](https://github.com/flyinghead/flycast)'s libretro core with the speed
changes from [Deadcast](https://github.com/tyrannotorus/emulator-dreamcast-deadcast) ported in,
built for [Leaf](https://github.com/Utility-Muffin-Research-Kitchen) on the Miniloong Pocket 1
(RK3566, Mali-G52, GLES 3.2). It runs in Leaf's own RetroArch beside the stock flycast core.
The name owns the jank: Deadcast trades accuracy for speed, and so does this.

Credit for the emulator goes to flyinghead and Flycast's contributors; credit for the speed work
goes to tyrannotorus (Deadcast). Mistakes in the port are ours.

## Building

Flycastrophe is upstream's libretro build with one extra switch:

```
cmake -S . -B build -DLIBRETRO=ON -DFLYCASTROPHE=ON -DUSE_GLES=ON -DUSE_VULKAN=OFF \
      -DUSE_OPENMP=OFF -DCMAKE_BUILD_TYPE=Release
cmake --build build --target flycast_libretro
```

`FLYCASTROPHE=ON` names the output `flycastrophe_libretro.so`, reports the library as
"Flycastrophe", keeps shared VMUs in `<system>/dc/flycastrophe/`, and leaves out the per-pixel
(GL4) renderer. Flycastrophe's own glue stays behind that switch or in `core/flycastrophe/`;
Deadcast's ports change Flycast's files where they must and keep Deadcast's new files in
`core/deadcast/`, as Deadcast names them. The device build, packaging and
releases live in [Flycastrophe-pak](https://github.com/Helaas/Flycastrophe-pak).

## Keeping up with both upstreams

- **Flycast:** `main` follows `upstream/master` by merge, through a pull request. No rebases,
  no force-pushes.
- **Deadcast** has no shared history with Flycast (its tree is Flycast `1b63c8a` plus its own
  squashed work), so its changes arrive as file diffs. Each port is one pull request, each
  commit names the Deadcast commit it takes from, and this ledger records the outcome.

## Ledger

Deadcast reviewed through **`82b57f2571`** (2026-11-07).

Status: **ported** (taken as is), **adapted** (taken with Flycastrophe glue), **pending** (not yet
done), **skipped** (will not be taken, with the reason).

| # | Topic | Deadcast source | Option / switch | Status |
| --- | --- | --- | --- | --- |
| 00 | Bootstrap: `FLYCASTROPHE` switch, own VMU folder, GL4 out | none | `-DFLYCASTROPHE=ON` | done |
| 01 | Perf counters (core only) | `3e3b549579` profiler, `110019952a`, `12fe9e85fe`, `117a12188d`, `055a8c6701`, `6c0c3f68a6` | env `FLYCASTROPHE_PERF=1` | pending |
| 02 | Texture DMA unprotect | `9cda9c4082` | none | ported |
| 02b | CHD read-ahead | `3e3b549579` chd.cpp | none | pending: neutral on still scenes, possibly slower on a moving replay (a non-sequential read waits for the prefetch in flight); retest with a streaming-heavy measurement |
| 03 | AICA thread (netplay journal stripped) | `3e3b549579`, `3299519ff9`, AICA half of `d1be34d557` | `reicast_fcr_threaded_audio` | pending |
| 04 | 4 GB memory window + fault rewrite | `3e3b549579` addrspace, posix_vmem, virtmem, sh4_mmr | none | pending |
| 05 | Pinned-register dynarec, thunks, inline IRQ, SQ to TA direct | `3e3b549579`, `d1be34d557`, `f42955105f` | env `FLYCASTROPHE_NO_PIN` | pending |
| 06 | NEON fipr/ftrv | `3e3b549579` rec_arm64 | `reicast_fcr_fast_fipr` | pending |
| 07 | Idle-loop skips | `3e3b549579`, `b1b0cb1744` | `reicast_fcr_idle_loop_skip` | pending |
| 08 | 28-byte vertex, Naomi 2 normals in their own GL buffer | `3e3b549579` ta_ctx.h, ta_vtx.cpp, elan.cpp, sorter.cpp | none | pending (adapted) |
| 09 | TA parse thread | `3e3b549579` Renderer_if.cpp, ta_ctx.cpp | env | pending |
| 10 | Unchanged textures not re-uploaded | `3e3b549579` TexCache, `ff68543516` (TexCache part) | none | pending |
| 11 | Frameskip on lag, audio fill | `f212a71804`, `1b8db315e8` | `reicast_auto_skip_frame` | pending |
| 12 | Sorting heuristics, Daytona exception, fast GD-ROM load default | `3e3b549579` ta_util, `564410027b`, `a7ed1b550b` | default change | pending |
| 13 | MMU windows, versioned block cache (Windows CE) | `3e3b549579` mmuwindows, `a7ed1b550b` | none | pending |
| 14 | Code cache on disk | `9909d48688`, `f42955105f` | env | pending |

After the review point, not yet reviewed: `9ffccd7c7f` (frame skip always at its most),
`b5854cb951` (Options pages).

### Skipped

Vulkan renderer work. Flycastrophe renders with GLES because on the Miniloong Pocket 1 the
SH4 thread, not the renderer, is the limit, and Vulkan through Leaf's Weston measured 1-2% slower
than GLES with the stock core:

- GpuAllocator replacing VMA (`core/rend/vulkan/allocator.*`).
- Precompiled SPIR-V and specialization constants (`core/rend/vulkan/shaders/`).
- Descriptor cache, bind skipping, batched modifier volumes, lazy depth buffers, GPU timer
  (`drawer`, `pipeline`, `commandpool`, `gputimer.h`).
- The texture upload worker's decode into Vulkan staging memory (`ff68543516`); GL reports the
  hook as unsupported and uploads as before.
- Handing the Vulkan image straight to the frontend; Vulkan renderer perf counters.
- The Vulkan per-pixel (OIT) renderer, and on GL the GL4 per-pixel renderer (no second volume
  to draw with the 28-byte vertex).

Not part of a libretro core: the recomp system, `ui/`, the store, Deadcast's menu,
`linux-dist/main.cpp`, `shell/brick/*`, the Brick panel presenter (`panel.cpp`) and its DSI
register write (`f8e4afe003`), the SDL audio backend (`b7537ce331`, `399d2f674f`), netplay and
link cable (`395653a2a1`, `821fd559d8`, `8e68988667`), forced NTSC/VGA, `fc84aa2d87`,
`56d273596c`, `82b57f2571` (per-game settings in Deadcast's menu).
