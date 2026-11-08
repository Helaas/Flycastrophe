# First level load lag (2026-11-08)

Reported on the device: Crazy Taxi, launched from Leaf and started straight into the arcade level,
is "pretty laggy" for a while after the level loads, then fine. After an in-game reset, the same
level isn't laggy.

## Measured

Leaf's RetroArch with the bench config, core `f600a9b0` (fork `b37fbb1`, the pinned build), the
user's own `Flycastrophe.opt` from the card (DSP on, anisotropy "4", Auto Skip Frame "more", delay
frame swapping on), CPU, GPU and memory governors at "performance" as Leaf sets them for a game,
`FLYCASTROPHE_PERF=1`. Booted with no state, menus stepped by hand (Arcade, arcade rules, Axel),
then the bench's Crazy Taxi drive script. `perfsum.py` condenses the perf lines; `t` is seconds
since the first one, `rend` and `skip` are frames shown and skipped per second, `rmax` the slowest
render, `comp`/`compms` the blocks compiled and the time it took, `fmax` the longest interval
between two emulated vblanks.

| | Level load | First 10 s of the level, frames shown per second |
| --- | --- | --- |
| Fresh boot (`before-fresh-boot.txt`) | 4059 blocks in 188 ms, render max 236 ms, 114 textures, lag +36.7 ms | 33, 20, 21, 27, 32, 35, 40, 42, 44, 50 |
| After an in-game reset (`before-after-in-game-reset.txt`) | 2 blocks, render max 40 ms, lag +2.3 ms | 56, 60, 60, 60, 60, 54, 58, 57, 55, 60 |
| Fresh boot, lag capped per interval (`after-fresh-boot.txt`) | 4147 blocks in 198 ms, render max 195 ms, lag +6.3 ms | 23, 56, 60, 60, 51, 60, 60, 58, 60, 59 |

The emulation keeps full speed through all of it (vblank 59-61/s). On a fresh boot the level load
stalls for a few hundred ms while the dynarec compiles the level's code and the GL renderer builds
its shaders and uploads its textures. Counted in full, that stall pinned the lag at its 50 ms cap,
and since RetroArch runs the SH4 at real time it could only work the lag off a few ms per second:
Auto Skip Frame ("more", two in a row) dropped up to 2 frames in 3 for about 10 s. After an
in-game reset the code, shaders and textures are already there, so there's no stall to count.

## Fix

Two changes to the lag behind Auto Skip Frame (`core/hw/pvr/spg.cpp`):

1. **Each vblank interval adds at most one frame of lateness.** A burst's wait (RetroArch's
   pacing, a frame) and steady slowness (a few ms every frame) count as before; a stall of 0.2 s
   counts as 16.7 ms. The stall itself is unchanged (fixing it means a warm code cache at boot and
   a GL program cache); it now costs about a second of skipped frames instead of ten
   (`after-fresh-boot.txt`).
2. **Lag over 0 fades, 2% a vblank.** Under RetroArch audio sync holds the SH4 to real time, so
   lag left over the threshold had nothing to bring it back down: with the CPU at 1.1 GHz, runs
   of the same scene either climbed back to 60 fps or sat at 20-36 fps for the whole window,
   whichever way the start went, with the old core and with change 1 alone
   (`fcr-phase0-20261108-232904-lagcap-slow`). With the fade, slowness of more than about 1% (lag
   over 8 ms at 2% a vblank) still turns the skip on.

## Frame skip still works (CPU at 1.1 GHz)

The row 11 method: `scaling_max_freq` 1104000 (restored after), governors at "performance",
`core-options-fcrskip.cfg` (Auto Skip Frame Maximum), state + drive script, capped, 10 s warmup +
30 s. Frames shown per 5 s of the window, from RetroArch's frame count
(`fcr-phase0-20261108-233950-lagleak-slow`, `fcr-b37` = the pinned `f600a9b0`, `fcr-leak` = both
changes, `278be58d`):

| Run | fcr-b37 | fcr-leak |
| --- | --- | --- |
| Crazy Taxi 1 | 34 32 34 41 52 60 | 60 60 60 60 60 60 |
| Crazy Taxi 2 | 42 57 39 45 51 50 | 38 53 60 60 60 60 |
| Crazy Taxi 3 | 51 39 30 41 20 21 | 35 50 50 54 52 53 |
| SA2 1 | 50 49 32 27 35 37 | 60 60 60 60 60 60 |
| SA2 2 | 49 59 60 60 60 60 | 60 60 60 60 60 60 |
| SA2 3 | 56 60 60 60 60 60 | 60 60 43 32 46 49 |

Median fps Crazy Taxi 41.1 to 59.6, SA2 59.3 to 60.0; audio underruns Crazy Taxi 1.9% to 3.9%,
SA2 0.9% to 1.7% (with the skip off this setup underran 32.7% in row 11). The skip still drops
frames where the scene needs it (SA2 run 3).

`after-fade-fresh-boot.txt` is a fresh boot with both changes, the same steps as the others; it sat
on the title screen longer and compiled about 5,000 more blocks before the level, so its level
load stalled less (586 blocks, render max 65 ms): lag peaked at -21 ms and nothing was skipped.
