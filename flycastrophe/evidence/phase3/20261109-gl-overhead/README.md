# GL overhead and the first profiles (2026-11-09)

Follow-up to an outside review of where Flycastrophe could still gain without losing picture
quality. Dev builds of fork `main` (`43b4c67b`, the code of `11edbf1`) without PGO, as the profile
fits the pinned commit only.

## Changes

- **Profiler wired up.** Deadcast's sampling profiler (`core/deadcast/profiler.cpp`) was ported
  but nothing started or dumped it. Now the emulation, AICA and parse threads and the renderer's
  thread (RetroArch's main thread under libretro) register, and `Emulator::unloadGame` dumps while
  the translated blocks still exist. A thread started again under the same name (the emulation and
  AICA threads, on every state load) carries on in its slot; before, the restarts used up the
  four slots and the parse and render threads went unsampled. Off unless `DEADCAST_PROF` is set.
- **GL work on the perf line.** `gl per render: draws, programs, textures`: draw calls, and the
  program and texture binds that changed state.
- **glsm restores 4 texture units, not all of them.** libretro-common's GL state manager rebinds
  and then clears every unit the GPU has (`GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS`) on every
  `retro_run`; the GLES renderer uses units 0-2 (textures, fog table, palette). Units past the
  core's keep the frontend's bindings. `rglBindTexture` no longer records a unit past the array.
- **Vertex and index buffers orphaned before upload.** `GlBuffer::update` overwrote the store at
  offset 0 with `glBufferSubData`; it now calls `glBufferData(NULL)` with the same size first, so
  the driver can hand back fresh memory instead of syncing with or copying the previous frame's.

## Bench (`fcr-phase0-20261109-201434-gl-uncapped`)

Uncapped still scenes, 3 rounds, order rotating, performance governors. `fcr-gl0` = the profiler
and counters only, `fcr-glsm` + the glsm cap, `fcr-orphan` + orphaning, `fcr-glboth` both.

| Arm | Crazy Taxi fps (rounds) | SA2 fps (rounds) |
| --- | --- | --- |
| fcr-gl0 | 70.58 (70.8, 70.4, 70.5) | 92.04 (92.5, 91.7, 91.7) |
| fcr-glsm | 71.96 (71.2, 73.3, 72.0), +2.0% | 91.37, -0.7% |
| fcr-orphan | 72.82 (73.6, 71.2, 74.0), +3.2% | 91.94, -0.1% |
| fcr-glboth | 72.87 (72.4, 73.4, 72.9), +3.2% | 91.92, -0.1% |

Crazy Taxi is limited by RetroArch's thread (the GL calls); every run with either change beat
every baseline run. The two don't add up, and the spread is too wide to split the 3% between
them. SA2 is limited by the emulation thread, and doesn't move.

## Profiles (`profile-*.txt`)

`fcr-glboth` with `DEADCAST_PROF` and `FLYCASTROPHE_PERF=1`, uncapped, 35 s from each bench state
(`bench/flycastrophe/profile-run.sh`), summarized by `bench/flycastrophe/profsum.py` against the
build's linker map (Flycastrophe-pak `LINK_MAP=1`). The CPU-time timer fires at most once per
kernel tick, so the sample counts are below one per millisecond, but the shares hold. The dumps
themselves aren't kept: they hold the games' translated code and SH4 disassembly.

- **Crazy Taxi, RetroArch's thread:** 74% of its samples in the Mali driver (`libmali`), another
  6% in libc called from the driver; the core's renderer about 11% (`DrawList` 3.4%,
  `SetTextureRepeatMode` 1.8%, `SetGPState` 1.4%). Per frame about 580 draw calls, 230 program
  changes and 430 texture binds. The renderer-bound lever is fewer draws and state changes per
  frame, not faster core code.
- **The Katana wait loop, both games:** the hottest SH4 code in both is the same loop at different
  addresses: call a callback (here an empty `rts; nop` function), compare a timeout counter, loop
  while a flag stays set. It takes 66% of SA2's guest cycles and 23% of its emulation thread's
  samples (Crazy Taxi: 53% and about 20%). Deadcast's idle-loop detection doesn't match it (perf
  line: wait turns skipped 0, asleep 0%). Recognizing it and sleeping to the next scheduler event
  is the fidelity-neutral form of the SH4 underclock the review measured (+6% on SA2 at 150 MHz).
