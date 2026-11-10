# Flycastrophe port ledger

What Flycastrophe has taken from [Deadcast](https://github.com/tyrannotorus/emulator-dreamcast-deadcast),
what it left out, and why. What Flycastrophe is, how fast it is and how to build it:
[README.md](README.md). The plan and the measurements behind each row: [flycastrophe/](flycastrophe/README.md).

## Keeping up with both upstreams

- **Flycast:** `main` follows `upstream/master` by merge, through a pull request. No rebases,
  no force-pushes. `README.md` is Flycastrophe's own: on a merge conflict there, keep ours and look
  at what upstream changed.
- **Deadcast** has no shared history with Flycast (its tree is Flycast `1b63c8a` plus its own
  squashed work), so its changes arrive as file diffs. Each port is one pull request, each
  commit names the Deadcast commit it takes from, and this ledger records the outcome.

## Ledger

Deadcast reviewed through **`a7f9a6b`** (2026-11-10).

Status: **ported** (taken as is), **adapted** (taken with Flycastrophe glue), **pending** (not yet
done), **skipped** (will not be taken, with the reason).

| # | Topic | Deadcast source | Option / switch | Status |
| --- | --- | --- | --- | --- |
| 00 | Bootstrap: `FLYCASTROPHE` switch, own VMU folder, GL4 out | none | `-DFLYCASTROPHE=ON` | done |
| 01 | Perf counters (core only) | `3e3b549579` profiler, `110019952a`, `12fe9e85fe`, `117a12188d`, `055a8c6701`, `6c0c3f68a6` | env `FLYCASTROPHE_PERF=1` | adapted: the perf line's names and format, the part that applies under RetroArch (emulated vblanks, lag, renders, the SH4, render and AICA threads' CPU, waits, texture updates and repeats, compiles, wait loops, MMU); no presenter, GPU, audio backend or trace parts; Deadcast's sampling profiler came with row 04; GL draws, program and texture changes per render added 2026-11-09. The sampling profiler (`DEADCAST_PROF`) came with the dynarec unit but was never started: wired up 2026-11-09 (emulation, AICA, parse and render threads, dumped at unload; a restarted thread keeps its slot) |
| 02 | Texture DMA unprotect | `9cda9c4082` | none | ported |
| 02b | CHD read-ahead | `3e3b549579` chd.cpp | none | skipped: disc reads take under 1% of a thread on the MLP1. Timed per read: Crazy Taxi's city streaming 606 ms without, 670 ms with (one 26 ms wait on a prefetch in flight); SA2 and CD audio (Sega Rally 2) reads halved to quartered, but they were 3-5 ms a second |
| 03 | AICA thread (netplay journal stripped) | `3e3b549579`, `3299519ff9`, AICA half of `d1be34d557`, `52cfec5` | `reicast_fcr_threaded_audio` (on) | ported; GD-ROM sector reads locked (`imgread/common.cpp`), since CD audio reads the disc from the AICA thread; Flycastrophe stops the thread as a game unloads (RetroArch unloads the core without `term()`) |
| 04 | 4 GB memory window + fault rewrite | `3e3b549579` addrspace, posix_vmem, virtmem, sh4_mmr | none | ported with 05, 06, 07, 13 as one dynarec unit (SA2 +23.2%, Crazy Taxi +2.0%) |
| 05 | Pinned-register dynarec, thunks, inline IRQ, SQ to TA direct | `3e3b549579`, `d1be34d557`, `f42955105f` | none (Deadcast has no switch) | ported (dynarec unit, row 04) |
| 06 | NEON fipr/ftrv | `3e3b549579` rec_arm64 | `reicast_fcr_fast_fipr` (on) | ported (dynarec unit, row 04); with row 07 worth ~3% on SA2 |
| 07 | Idle-loop skips | `3e3b549579`, `b1b0cb1744` | `reicast_fcr_idle_loop_skip` (on) | ported (dynarec unit, row 04); Flycastrophe adds the Katana library's callback wait (2026-11-09: Sonic Adventure 2, Crazy Taxi, Sonic Adventure, Power Stone; uncapped SA2 +8.5%, `flycastrophe/evidence/phase3/20261109-katana-callback-wait/`) |
| 08 | 28-byte vertex, Naomi 2 normals in their own GL buffer | `3e3b549579` ta_ctx.h, ta_vtx.cpp, elan.cpp, sorter.cpp | none | adapted (Crazy Taxi +1.6%, SA2 +0.5%; VF4 lighting checked) |
| 09 | TA parse thread (GL: textures fetched on RetroArch's thread) | `3e3b549579` Renderer_if.cpp, ta_ctx.cpp, ta_vtx.cpp | `reicast_fcr_parse_thread` (on) | ported (Crazy Taxi +10.1%, SA2 -2.6%) |
| 10 | Unchanged textures not re-uploaded | `3e3b549579` TexCache, `ff68543516` (TexCache part) | none | ported; neutral on the bench (Crazy Taxi -0.2%, SA2 -1.4%, within noise), for games that rewrite textures unchanged |
| 11 | Frameskip on lag, audio fill | `f212a71804`, `1b8db315e8` | `reicast_auto_skip_frame` (Maximum) | adapted: skip on lag (`f212a71804`), lag credited for running ahead (RetroArch paces the SH4 in bursts); audio veto `1b8db315e8` skipped (RetroArch's buffer reads 20-100% full on Leaf while underrunning, so it vetoed every skip). Full clock: no skips. At 1.1 GHz: Crazy Taxi underruns 32.7% to 1.2% for 49.5 to 47.0 fps shown. Under RetroArch a vblank interval counts at most one frame of lateness and lag over 0 fades 2% a vblank, since audio sync holds the SH4 to real time and nothing else worked lag off: a fresh boot's first Crazy Taxi level load had skipped up to 2 frames in 3 for 10 s (`flycastrophe/evidence/phase3/20261108-first-load-lag/`) |
| 12 | Sorting heuristics, Daytona exception, fast GD-ROM load default | `3e3b549579` ta_util, `564410027b`, `a7ed1b550b` | default change | ported; Flycastrophe also sorts the European Daytona disc (`MK-5103750`) per triangle, decals checked in its attract race; neutral on the bench |
| 13 | MMU windows, versioned block cache (Windows CE) | `3e3b549579` mmuwindows, `a7ed1b550b` | none | ported (dynarec unit, row 04); Sega Rally 2 attract checked |
| 14 | Code cache on disk | `9909d48688`, `f42955105f` | none | adapted: `<content>.blocks` in RetroArch's save directory (`Saves/Flycastrophe/` under Leaf), written on a normal quit; no warm-up within 2 s of the last (rewind, run-ahead); each recorded block's code checked before it is decoded (a list from another save of the game made RetroArch abort, found with an upstream issue's state); Crazy Taxi 5890 blocks in 313 ms, SA2 7741 in 433 ms. Since row 17, Deadcast's own checks (a versioned list, protected blocks only) |
| 17 | Faster SH4 dynarec: writes next to code, store queue and timer accesses inline, FR0-FR15 pinned, on-chip RAM at `7E000000`, a code page unlocked when its last block goes | Deadcast PR #2: `84803c4`, `330b4d6`, `87e42bf`, `59fd4db`, `9910de3`, `3fd6b02`, `1fa00cb`, `c3e83b5`, `6084a68`, `d872c22`, `f28de39` | none (Deadcast has no switch) | ported; row 06's switch kept (with it off, the exact op is called through the full thunk, which keeps the pinned FR registers), Deadcast's code cache checks replace row 14's. It takes work off the emulation thread rather than adding frames where the renderer is the limit: NFL 2K2's saved play 43% to 35% of a core at the same speed (19% less SH4 time per emulated second); the BIOS boot animation 91% to 103% speed; DOA2 and Project Justice boots 11% and 26% less SH4 time per emulated second (`flycastrophe/evidence/phase3/20261110-deadcast-pr2/`) |

Since `82b57f2571`: `52cfec5` (Threaded Audio on by default) ported with row 03; `9ffccd7c7f`
(frame skip always at its most) taken as row 11's default, with the option kept; `b5854cb951`
(Options pages, `ui/`), `039413c` (1.2.4), `6822371` (Pak Store screenshots) and `b24817b`
(README) have nothing for a libretro core.

Since `b24817b`: Deadcast PR #2 is row 17. Its `0244915` and `3ecb3a0` (native loops for the 2K
engine) were taken out again in `5d46c54`; `de2c4f6` (trilinear alpha) is in the Vulkan renderer,
which Flycastrophe doesn't build; `a7f9a6b` (1.2.5) has nothing for a libretro core.

Rows 04, 05, 06, 07 and 13 are interleaved in Deadcast's `rec_arm64.cpp` and depend on each other,
so they were ported as one unit (Deadcast's files as Deadcast has them, then Flycastrophe's option
glue), not one pull request per row.

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
