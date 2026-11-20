# Armada's SH4 thread profiled: how much is MMU work (2026-11-19)

Armada is a Windows CE game, so it runs on the full MMU path, and in open space its emulation (SH4)
thread is the limit (77-100% of a core, speed 81-96%; `flycastrophe/plan.md`, slow scenes). The
question was what share of that thread is MMU work, and whether a per-address-space lookup table
would be worth building if that share passed about 10%. Result: it does not, so no change is
proposed. No code was changed for this; base `1d7ef4ed`, a dev build without PGO, one MLP1.

## Method

`DEADCAST_PROF` sampling profiler (CPU-time timer per thread), symbolised with the build's link map.
From `armada-base.state` with RT held (`drive-armada-rt.txt`), about 70 s as played, capped
(`armada-prof.sh`). `profsum.txt` is the emulation thread, `profsum-all.txt` every thread,
`emu-funcs.txt` the emulation thread by function, `armada-retroarch.log` the perf lines.

## Result

Emulation thread, 21,383 samples:

| | share |
| --- | ---: |
| generated code (the game and Windows CE) | 87% |
| core functions | 11% |
| libraries | 2% |
| of which MMU-named functions (lookup, misses, dispatch-cache flush, store-queue writes) | 2.7% |
| of which P4 register access | 1.2% |
| the dynarec's loop and stubs | 5.6% |

Named MMU and P4 functions come to 3.9%. Only part of the 5.6% in the loop and stubs is MMU work,
so MMU work is at most about 9% of the thread. The perf lines show about 710-740 partial lookup-table flushes and
165,000-220,000 misses a second in play. The hottest single block of game code takes 8.6% of the
thread's samples.

## Conclusion

Below the 10% bar. A lookup table per address space would save at most the flush and refill part of
the MMU work, about 1-2% of the thread (projected). The cost is in the game's own code, so Armada's
open-space slowdown is out of reach for MMU changes.
