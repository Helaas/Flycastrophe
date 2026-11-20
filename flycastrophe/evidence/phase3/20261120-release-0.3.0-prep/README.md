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

## Release (2026-11-20)

- **Pin:** Flycastrophe-pak `7afeaabe` (Helaas/Flycastrophe-pak#11) pins `main` at `aa6b3800`, whose code is the
  trained branch's. Two clean builds agree on the core: sha256 `958562b3054072df0552f09f20f8556fe3d3fc72f96b625a20a336bd72ebf117`,
  53,374,392 bytes. `make check` passes and CI rebuilt the same core.
- **Release core on the device** (`release-core-nfl2k2.txt`): the NFL 2K2 saved play with the default options,
  98.3% speed, 14.4 ms a render, 2.9 frames a second skipped.
- **Published:** [v0.3.0](https://github.com/Helaas/Flycastrophe-pak/releases/tag/v0.3.0), the unchanged zip
  from CI's run on the pak's `main` (`SHA256SUMS`), every packaged file identical to the local package. It was
  installed on the test card through Pak Rat before publishing (`pakrat-release-install/run.log`): core options,
  the DC core choice and per-game core rows unchanged.
- **Catalog:** leaf-docs#82, live with versions 0.3.0, 0.2.0 and 0.1.0, all gated on Leaf 0.14.0.
