# 0.3.0 release preparation (2026-11-20)

The profile for 0.3.0 was trained on a local branch holding #35, #36, #37 and #38 merged, plus two small fixes
(the regroup stays off with Native Depth Interpolation; the cache reset reason is guarded for builds without the
dynarec). The code is what `main` holds after those merges.

- **Training** (`train.log`, `train.sh`): the same set as 0.2.0. Spider-Man from three savestates, Ecco and Sonic
  Adventure for 60 s each; Dead or Alive 2 and Power Stone booted for 90 s. Crazy Taxi and Sonic Adventure 2 left
  out. 354 `.gcda` files. Build logs: `gen.log` (instrumented), `use.log` (optimized); no profile mismatch
  warnings, 71 missing-profile warnings in third-party libraries the games never run, as for 0.2.0.
- **Sanity bench** (`bench/summary.md`, `bench.log`): one round, uncapped still scenes, against the 0.2.0 release
  core. Crazy Taxi 92.65 to 94.65 fps, SA2 113.86 to 113.79 fps. One round is inside the bench's spread: no
  regression, nothing more.
- **Boot check** (`boot-power-stone-30s.jpg`, `boot-check.sh`): Power Stone renders after 30 s.
- **Test install** (`pakrat-test-install/`): the trained core went onto the test card through Pak Rat's local feed
  as 0.3.0, updating 0.2.0 in place; core options, the DC core choice and per-game core rows unchanged.
- **Size:** the core is 53.4 MB on the card (30.3 MB for 0.2.0) because the 32 MB code cache sits in `.text`;
  the pak zip is 4.3 MB.

Not done here: a frame-exact comparison of the trained core against 0.2.0 (see
`../20261120-nfl2k2-gray-field/` for why the frame check cannot do it).
