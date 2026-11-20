# Sega Rally 2: attract against race (2026-11-20)

Why the game's 3D attract runs at half speed on the MLP1 while a race is close to full speed. Core: `main`
1d7ef4ed (0.2.0's code), dev build without PGO. Capped as played, bench core options (frame skip off),
performance governors for the run. `DEADCAST_PROF` and `FLYCASTROPHE_PERF`. All figures measured.

| | Attract (no input, 60-170 s) | Race (Arcade, Championship, Desert, 96-151 s) |
| --- | --- | --- |
| Speed | 50.3% mean (41.7-85.0) | 95.4% mean (87.0-101.4), 23 of 55 seconds under 95% |
| SH4 thread | 100% | 99% |
| Render thread | about 16% | 22-31%, 3-4 ms a render |
| Full + partial MMU flushes a second | 54-62 + about 650 | 0 + about 1,300 |
| Lookup misses a second | 45k-57k | 23k-38k |
| Translated code | 53% (18% live blocks, 35% blocks gone by quit) | 87.6% |
| MMU work | at least 41% | about 3% |

**Attract** (`attract-60-170.txt`): the game invalidates the whole TLB (MMUCR.TI) about twice per emulated
frame. Each one empties the address window, and every page is mapped again through a fault. The SH4 thread's
samples: libc under `mmuwin::mapPage` 13.9%, under `CCN_MMUCR_write` 6.1%, under `mmuwin::clearWindow` 4.9%;
`fault_handler` 10.0%; the MMU's own functions 6.1%. The kernel's time delivering each fault is charged to the
faulting translated code, so 41% is a floor. Armada never does a full flush, which is why its profile
(`../20261119-armada-profile/`) looks nothing like this.

**Race** (`race-96-151.txt`): no full flushes, 87.6% translated code, nothing in the MMU worth chasing. The run
held the accelerator only, so the car left the road and sat against a barrier for part of it: not a clean lap.

Not changed: the attract only plays when nobody presses Start, and keeping the window across a full flush is a
correctness risk for every Windows CE game. Worth revisiting if a Windows CE game shows full flushes in play
(the first number of the perf line's `mmu flushes A+B`).

`profsum.py` ties a sample to a block at quit, so blocks dropped before quit show as "[dynarec loop/stubs]"
(33% in `profsum.txt`, the whole run). `tools/window.py` splits them by address (the real loop and stubs are
2.9% in the attract, 4.9% in the race) and limits the samples to a time window.

Menu path to the race from boot: START (skips logos), START (title), A (Championship), A (car), A (transmission),
A (name END), A. `tools/sr2-prof.sh` runs the attract; `sr2-race-start.sh`, `sr2-step.sh` and `sr2-race-end.sh`
step to the race by hand. The raw sample dumps stay out of the repository.
