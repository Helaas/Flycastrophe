# SA2's mid-level stall: the dynarec's code cache fills (2026-11-19)

Ledger row 20. On 2026-11-11 a City Escape session showed one second at 20% speed, 307 s in, with a
full dynarec cache clear (`flycastrophe/plan.md`, slow scenes). Dev builds without PGO on one MLP1,
base `1d7ef4ed`, capped, with audio sync.

## Cause

The code cache is 10 MB. It is emptied when less than 32 KB is free, and space taken by a block that
is thrown away (a stage load overwrites the game's code) is never reused. SA2 booted from the BIOS
with no input runs its attract stages one after another. After 326 s the cache held 6.7 MB of live
code and 3.5 MB of dropped blocks, so it was emptied mid-stage, and 7,119 blocks were recompiled in
0.9 s:

```
Flycastrophe cache reset: code cache full at pc 8C0868F2, used 10209 of 10240 KB,
  live blocks 28752 in 6717 KB, dead 3491 KB, compiled since start 47712
perf  326.2 s: vblank 12.24/s  20.4% ...  compiled 7119 in 891.9 ms resets 1
```

Every other reset in the run is the BIOS (boot addresses, the SH4 reset at load and at quit).
Playing on from `sa2-hero-intro.state` for 320 s compiled 21,500 blocks into 5.3 MB and did not fill
the cache (`sa2-state-10mb.log`), so it takes stage changes to get there.

## Fix

`CODE_SIZE` 10 MB to 32 MB (`a62cc185`). The same boot, the same 340 s:

| | 10 MB | 32 MB |
| --- | ---: | ---: |
| full-cache resets | 1, at 326 s | none |
| speed at 324-328 s | 100%, 99.5%, **20.4%**, 100% | 100%, 100%, 100%, 100% |
| mean speed after 20 s | 99.0% | 99.3% |
| worst second after 20 s | 20.4% (the reset) | 79.4% (a stage load at 52 s; 70.7% there with 10 MB) |
| cache used at quit | 3.9 MB (refilled after the reset) | 10.6 MB (6.2 MB live, 4.5 MB dropped) |

The cache is declared in `.text`, so the core grows from 29.6 MB to 52.7 MB on the card. Gzipped, as
Pak Rat downloads it, it grows by 24 KB. Pages of the cache that are never written are never read
into memory.

## Logging

`12222533` logs each `ResetCache` at NOTICE with its reason (code cache full, boot address, block
check failed, MMU switched, SH4 reset), the pc, the cache used, and the live and dropped code in it.
That is how the cause was found. A reset happens a handful of times a session, so the cost is a walk
over the live blocks each time.

## Not checked

- How long 32 MB lasts. From the 10 MB run's rate, 32 MB fills after roughly 15-20 minutes of attract
  stages back to back (projected, not measured). Ordinary play changes stages far less often. A cache
  that reuses the space of dropped blocks would end this for good, but that is a larger change.
- Other games that load new code often (Windows CE titles, Shenmue).
- Memory on a 1 GB card with other things running: the extra space is only touched as code fills it.
