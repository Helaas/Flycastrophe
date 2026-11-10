# Deadcast's faster SH4 dynarec (2026-11-10)

[tyrannotorus/emulator-dreamcast-deadcast#2](https://github.com/tyrannotorus/emulator-dreamcast-deadcast/pull/2),
"Faster SH4 dynarec for every game", merged into Deadcast as `a7f9a6b4`. Ledger row 17.

## What came over

The pull request's net change over Deadcast `b24817b`, all of it in the dynarec and memory code:

- Writes next to code go through: only the blocks whose code or folded constants changed are
  thrown away, the page stays protected, and a word that was written is never folded again
  (`84803c4`, `330b4d6`, `87e42bf`, `6084a68`; `59fd4db` closes the window between a write to
  protected code and its check).
- Stores to the store queues, TMU count reads and store queue writes to RAM compiled inline
  (`9910de3`, `3fd6b02`).
- FR0-FR15 pinned in s16-s31 across blocks, as R0-R15 already were (`1fa00cb`).
- A code cache list compared with RAM before it is decoded, versioned, protected blocks only
  (`c3e83b5`).
- On-chip RAM at `7E000000` as well as `7C000000`: the BIOS keeps its stack there (`d872c22`).
- A code page unlocked when its last block goes (`f28de39`).

Not taken: `0244915` and `3ecb3a0` (native loops for the 2K engine; Deadcast took them out again
in `5d46c54`), `de2c4f6` (Vulkan renderer), `a7f9a6b` (version).

Where Flycastrophe differs from Deadcast's files: the code write counters go on Flycastrophe's
perf line (`spg.cpp`); the fast fipr/ftrv switch (row 06) stays, and with it off the exact op is
called through the full thunk, which stores and reloads the pinned FR registers; Deadcast's code
cache checks replace the ones from #16 (`codecache.cpp`, `driver.cpp`).

## Measurements

Dev builds without PGO. `main` is fork `main` (`c7ab46c1`; `25a0dc17` for the earlier runs, the
same code). This branch's tree is the one benched as `fcr-dcpr2b` (core `2c6e7566`); the earlier
runs used the pull request as of `d872c22d` (`fcr-dcpr2`, before the page unlock fix).

**The emulation thread does less** (`sh4-cost.txt`, `nfl2k2-saved-play.txt`):

| Run | main | This branch |
| --- | --- | --- |
| NFL 2K2 saved play: SH4 thread CPU per emulated second | 0.844 s | 0.684 s (-19%) |
| NFL 2K2 saved play, uncapped: emulation thread | 43% of a core | 35% |
| Dead or Alive 2 boot: SH4 CPU per emulated second | 0.489 s | 0.433 s (-11%) |
| Project Justice boot: SH4 CPU per emulated second | 0.386 s | 0.284 s (-26%) |
| BIOS boot animation (10-20 s of DOA2 and Project Justice) | 82-83% speed | 105-107% |
| NFL 2K2 fresh boot, first 20 s | 90.9% speed | 103.3% |

**Frame rates where the renderer is the limit don't move.** NFL 2K2's saved play renders about
2,800 draws a frame in 32 ms: 56.2% speed on `main`, 56.6% here (3 rounds uncapped). Its attract
demo after a fresh boot is the same story (`nfl2k2-fresh-boot.txt`; the scenes differ run to run).
Crazy Taxi and SA2 still scenes, uncapped, 3 rounds (`bench-d872c22d.txt`): -2.0% and +1.3%,
inside the rounds' spread; capped both hold 60 fps with the same frame times and underruns.

**With the draw-call change (#29)** the renderer stops being the limit for NFL 2K2, and the two
add up: the saved play at 97.4% speed with both (98.0% with #29 alone), the emulation thread at
67% of a core instead of 82%. Frames drawn from the same input are identical with and without
this change (85 of 85 compared, against a control run).

## Games

The earlier build (`d872c22d`) played Spider-Man (three states), Ecco, Sonic Adventure, Dead or
Alive 2 and Power Stone (boots) and Sega Rally 2 (Windows CE, MMU) at 57-61 emulated vblanks a
second with no errors, reaching the same points as `main`. Sega Rally 2's black frames during its
fades are on `main` too. NFL 2K2 plays on this branch's build (saved play and a fresh boot to the
attract demo).
