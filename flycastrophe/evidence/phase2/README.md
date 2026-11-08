# Flycastrophe Phase 2: bench method and per-PR results

Device: MLP1 `b1622a9e81b735ad`, Leaf's GLES RetroArch, Leaf-mirroring `retroarch.cfg`, bench core
options (`threaded_rendering` on, per-strip sorting, 640x480), CPU/GPU/DMC governors on
`performance`. Runner: `tmp/dc-core-bench/flycastrophe/bench.sh` + `summarize.py` (unversioned
harness; arms `fcr-<name>` = `out/fcr-<name>_libretro.so`, the first arm is the baseline).

## Method (settled 2026-11-07 with the user)

- **Primary: still scenes, uncapped.** The `upstream-{crazy-taxi,sa2}.state` savestates with no
  input, vsync and audio sync off: how fast the core runs the same scene. Rep-to-rep spread
  0.3-1.7% (Crazy Taxi) and up to 3.8% (SA2); no throttling in any run (1992 MHz CPU, 800 MHz
  GPU throughout). A change under ~2% does not show either way. They exercise everything that
  runs every frame (game code, AICA, rendering) but not streaming.
- **Moving replays are noisy, so secondary only.** `record-replay.sh` records a RetroArch input
  replay (`-R … -e 0`; the `RECORD_REPLAY` network command is not handled, and `--eof-exit`
  does not quit RetroArch 1.22.2, so the runner times the end from the log). Playback is
  frame-locked, but with threaded rendering on the core reads that input at host-timing-dependent
  emulated moments, so the game diverges: Crazy Taxi splits into ~54 or ~65 fps runs (different
  traffic by 13 s in; `20261107-204959-pr02-replay/crazy-taxi-*-r1/start.png`), SA2 holds for
  about a minute then drifts. Threaded rendering off makes replays nearly repeatable (end times
  1.6% apart) but runs at ~33 fps, a configuration nobody plays (`20261107-210606-tr-off-determinism`).
- **No warm-up round** (GLES has no pipeline cache). Quick check: 1 round; merge check: 2 rounds.
- **Capped runs** (vsync and audio sync on) only for PRs that touch pacing or audio.

## Results

| PR | Change | Still, uncapped (vs `fcr-main`) | Other | Outcome |
| --- | --- | --- | --- | --- |
| 02 | Texture DMA unprotect + CHD read-ahead | CT +0.1%, SA2 +0.5% (3 rounds) | SA2 replay -3.3% fps (noisy) | DMA merged (#2); CHD read-ahead back to pending |
| 03 | AICA thread | **CT +5.9%, SA2 +19.0%** (2 rounds) | capped: 60 fps held, underruns down; AICA thread 14% of a core | merged (#3) |
| 09 | TA parse thread (core option, on) | **CT +10.1%**, SA2 -2.6% (2 rounds, vs #3) | capped: 60 fps held; CT GL thread 94% → 83%, underruns 1.3% → 0.4% | merged (#4) |
| 08 | 28-byte vertex, Naomi 2 normals in their own GL buffer | CT +1.6%, SA2 +0.5% (2 rounds, vs #4) | parse thread 14% → 11%; RSS -5 to -8 MB; VF4 (Naomi 2) lit correctly, 45 s frame byte-identical (`20261107-vf4-naomi2-lighting/`) | merged (#5) |
| 04-07, 13 | Deadcast's dynarec as one unit: 4 GB window, pinned registers, NEON fipr, wait loops, MMU windows | **SA2 +23.2%, CT +2.0%** (2 rounds, vs #5) | capped: 60 fps held, SH4 thread 76-78% → 60-61%; options off: SA2 88.2 (fipr + idle skip ~3%); Sega Rally 2 (WinCE) attract loop, VF4, save/load checked (`20261107-dynarec-correctness/`) | merged (#6) |
| fix | AICA thread stopped as a game unloads | n/a | main's RetroArch exit after QUIT ended in `terminate called without an active exception` (`retro_deinit` never runs `term()` on Linux); clean after (`20261108-row12-14-aica-correctness/`) | merged (#7) |
| 10 | Unchanged textures not re-uploaded | CT -0.2%, SA2 -1.4% (2 rounds, vs #6) | CT replay 79.16 both, end 78.1 vs 78.2 s; SA2 replay diverged (different end frame), not comparable | merged (#8) |
| 12 | Receding-plane sort, Daytona per triangle (also the EU disc `MK-5103750`), per-strip and fast GD-ROM defaults | CT +1.1%, SA2 -0.9% (1 round) | Daytona USA 2001 (Europe) attract race: decals draw (`20261108-row12-14-aica-correctness/`) | merged (#9) |
| 14 | Code cache on disk (`Saves/Flycastrophe/<content>.blocks`) | CT +2.5%, SA2 -0.4% (1 round) | next state load compiles CT's 5890 blocks in 313 ms, SA2's 7741 in 433 ms; written on QUIT only (RetroArch skips the unload on SIGTERM) | merged (#10) |
| 11 | Lag-based frame skip (adapted: lag credited for running ahead, no audio veto), default Maximum | CT 71.00, SA2 91.40 (uncapped, = main) | capped full clock: no skips, 60 fps; CPU at 1.1 GHz: CT underruns 32.7% → 1.2% for 49.5 → 47.0 fps shown, SA2 p5 59.9 → 53.5; upstream's Maximum 14.8 / 11.8 fps | merged (#11) |
| fix | GD-ROM sector reads locked (CD audio reads from the AICA thread) | CT -0.9%, SA2 +0.1% (1 round) | Sega Rally 2 attract 150 s with CD audio and loads overlapping: no hang or crash (`20261108-chd-readahead-and-perf/`) | merged (#12) |
| 02b | CHD read-ahead, retested by timing every disc read | n/a | CT replay reads 606 → 670 ms (one 25.9 ms prefetch wait); SA2 and CD audio reads 2-4x shorter but 3-5 ms/s to begin with (`20261108-005019-chd-replay`) | skipped |
| 01 | Perf line (`FLYCASTROPHE_PERF=1`), the RetroArch-relevant part | off: CT -0.3%, SA2 -0.8% (2 rounds, opposite orders) | on: first frame after a state load renders in up to 593 ms (shader compiles) | merged (#13) |

After PR 03, Crazy Taxi's limit moves from the SH4 thread (99% → 86%) to RetroArch's GL thread
(92% → 99%): rendering is now the cap there. The ports that take work off that thread (TA parse
thread, row 09; 28-byte vertex, row 08) gain value. Row 09 confirmed it: +10.1% on Crazy Taxi,
while SA2 (still SH4-bound) pays ~2.6% for the extra thread, hence the option.

### Frame skip (row 11) method

A full-clock MLP1 runs both bench games at 60 fps, so the skip never has work. The CPU was capped
for these runs (`scaling_max_freq` 1104000, restored after) so Crazy Taxi falls behind (RetroArch's GL
thread 98%, the SH4 waiting a quarter of the time) and SA2 sits at the edge. Profile
`core-options-fcrskip.cfg` sets `reicast_auto_skip_frame` to Maximum; the baseline uses the bench's
default (disabled). Debug builds logged lag and skips every 300 frames (`fcrdbg.txt` in the
`r11dbg*` suites):

- Deadcast's audio veto, fed from `SET_AUDIO_BUFFER_STATUS_CALLBACK`: lag pinned at 50 ms, but
  RetroArch reported its buffer 20-100% full while underrunning 31%, so 0-5 skips per 120 frames
  (`20261108-000412-r11-slow-more`: same numbers as skip off).
- Lag alone, floored at 0 (Deadcast's `f212a71804`): at full clock ~57% of frames skipped and capped
  fps fell to 26-27 (`20261108-001325-r11dbg2-full`), since RetroArch's waits between bursts add up.
- Lag credited for running ahead (down to -50 ms): no skips at full clock in play; at 1.1 GHz about
  20% skipped and Crazy Taxi's underruns go from 32.7% to 1.2% (`20261108-001641-r11dbg3-*`,
  `20261108-002512-r11c-slow-more`, `20261108-003124-r11-slow-cd`). Threshold 17 ms measured the same
  as 8 ms.

