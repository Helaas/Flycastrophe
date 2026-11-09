# Profile-guided optimization (2026-11-09)

The pinned core (`11edbf1`, Flycastrophe-pak `e5961a8`, sha256 `077a9b91…`) already builds with
LTO (`CMAKE_INTERPROCEDURAL_OPTIMIZATION`); this adds GCC profile-guided optimization on top. The
build recipe lives in Flycastrophe-pak (`core/build-core.sh` `PGO=generate|use|off`, the profile
in `core/pgo/`, its record in the lock's `pgo` section, Helaas/Flycastrophe-pak#6); the training
script is `bench/flycastrophe/pgo-train.sh`. The PGO core was installed on the card through Pak
Rat for hands-on play.

## Recipe

- **Generate:** the pinned source with `-fprofile-generate=/tmp/pgo` added to the toolchain's
  release flags (sha256 `c61e391d…`). Every unit is instrumented: Flycastrophe has no naked
  functions or fixed registers, and nothing misbehaved, so FlyCast Fast UMRK's exclusions (its
  dynarec, memory and ARM7 units, for the 2022 source) weren't needed. The JIT's own output isn't
  compiled by GCC either way.
- **Use:** `-fprofile-use=/tmp/pgo -fprofile-correction -fprofile-partial-training`, the same
  flags as FlyCast Fast UMRK. 354 profile files, no coverage mismatches; 71 `-Wmissing-profile`
  warnings for functions training never ran, which `-fprofile-partial-training` optimizes as
  usual. Two builds from the profile agree (sha256 `a5d0729b…`), so the pak's CI can check it
  like any other pin, and `PGO=off` still reproduces `077a9b91…`.

## Training (`training/`)

Leaf's RetroArch with the bench config, performance governors, the core's defaults with Auto
Skip Frame off (so every frame is drawn), on the discs on the card:

| Run | Content | Time |
| --- | --- | --- |
| spiderman-0, -1, -2 | flyinghead/flycast#2191's three states, generic input loop | 60 s each |
| ecco | #1610's Ecco the Dolphin state, generic input | 60 s |
| sonic | #1600's Sonic Adventure state (Station Square) | 60 s |
| powerstone-boot | Power Stone from the BIOS into its attract demo | 90 s |
| doa2-boot | Dead or Alive 2 from the BIOS; it stopped on its save-file prompt | 90 s |

Each run quits RetroArch through its command port so libgcov writes and merges the counters
(`gcov-dump` reads all 354 files). The NAS share wasn't mounted, so the other issue states
(PSO Ver. 2, L.O.L., Tech Romancer, Vigilante 8, Evolution 2) weren't played. Crazy Taxi and SA2
are left out: the bench below measures the profile on games it hasn't seen.

## Bench

`fcr-rel11` = the pinned core, `fcr-pgo1` = the same source with the profile. Bench core options,
performance governors, 2 rounds with the order swapped, 10 s warmup + 30 s.

**Uncapped still scenes** (`*-pgo1-uncapped`), the primary measure:

| Game | fcr-rel11 fps (per round) | fcr-pgo1 fps (per round) | Change |
| --- | --- | --- | --- |
| Crazy Taxi | 71.65 (71.4, 71.9) | 74.09 (74.1, 73.6) | +3.4% |
| SA2 | 90.21 (90.0, 90.2) | 92.13 (92.0, 92.1) | +2.1% |

The rounds don't overlap. Frames match (`end.png` of each run, not kept here).

**Capped still scenes, audio on** (`*-pgo1-capped-still`): both hold 60 fps with the same frame
p95 and underruns; RetroArch's CPU over the window Crazy Taxi 178% to 173% of a core, SA2 147% to
144%.

**Capped, driving** (`*-pgo1-capped`): SA2 the same; one of the two Crazy Taxi PGO runs averaged
59.2 fps with 8.6% underruns. The drive script diverges between cores under threaded rendering:
that run ended in traffic with another car and a "stop and pick up a customer" banner, the
others against walls, so it isn't the same scene (the still-scene run above is).
