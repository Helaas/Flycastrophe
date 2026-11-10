# Draw-call cost in the GLES renderer (2026-11-10)

Where the RetroArch thread's GL time goes per draw on the MLP1, what cuts it without touching the
picture, and the two changes that came out of it (ledger rows 15 and 16). Dev builds without PGO.

## Result

| | main (`c7ab46c1`) | this change |
| --- | ---: | ---: |
| Crazy Taxi, uncapped still scene | 73.15 fps | 90.74 fps (+24.0%) |
| SA2, uncapped still scene | 99.90 fps | 112.92 fps (+13.0%) |
| NFL 2K2, 30 s of a saved play, two runs | 52.1%, 52.6% speed | 94.7%, 96.0% |
| NFL 2K2, the same capped | 52.7% | 92.0% |
| NFL 2K2 draws per frame | 2,585 | 815 |

- **Vertex range with every indexed draw (row 16).** The index buffer is new every frame, so Mali
  reads each draw's indices to find the vertices it uses. The parser already walks them, so it
  records each polygon's lowest and highest vertex and the renderer draws with
  `glDrawRangeElements`. A texture-changing draw drops from about 12 us to 7 us. This is the whole
  gain in Crazy Taxi and SA2, and SA2 is then limited by the SH4 thread (98% of a core).
- **Runs of one-triangle modifier volumes in one draw (row 15, from Deadcast's Vulkan renderer).**
  NFL 2K2 draws 550 to 1,030 shadow volumes a frame, each a single triangle, at two draws and six
  stencil calls each: 1,100 to 2,000 of its 1,900 to 2,800 draws. A volume of one triangle sets
  the stencil's area bit where the triangle is in front, whatever the order, so a run of them is
  one draw.
- **Same picture.** Frames paired between a build without and with the two changes are identical
  to the byte: 30,944 frames over 25 games, and 4,197 from the three bench scenes in both sorting
  modes, none different (section 5).

## 1. What a render asks of the driver

Measured with a counting build (a prototype, not part of this change): every GL call
that reaches the driver counted by kind and timed, a draw's time kept by what changed since the
draw before it, because Mali validates state at the draw. Unchanged renderer, uncapped, per render
(`prototypes/logs/*-main-counted-timed.log`):

| | Crazy Taxi | SA2 | NFL 2K2 |
| --- | ---: | ---: | ---: |
| Draws | 553 | 416 | 2,058 |
| of them for modifier volumes (volumes) | 58 (19) | 27 (8) | 1,285 (642) |
| Program changes | 220 | 22 | 69 |
| Texture binds | 408 | 361 | 734 |
| Uniform calls | 36 | 19 | 87 |
| Texture parameter calls | 151 | 94 | 82 |
| Blend / depth / cull / stencil calls | 12 / 45 / 163 / 163 | 10 / 24 / 0 / 84 | 216 / 1,292 / 273 / 3,871 |
| Draws with no state call before them | 19 | 11 | 0 |
| Indices | 13,768 | 11,789 | 32,569 |

| ms per render | Crazy Taxi | SA2 | NFL 2K2 |
| --- | ---: | ---: | ---: |
| `renderFrame` | 12.36 | 8.77 | 26.03 |
| Draw calls | 8.19 | 5.60 | 18.78 |
| `glBindTexture` | 0.65 | 0.53 | 0.83 |
| `glUseProgram` | 0.32 | 0.12 | 0.14 |
| Texture parameters | 0.20 | 0.13 | 0.06 |
| Uniforms | 0.05 | 0.04 | 0.06 |
| Blend, depth, cull, stencil, scissor | 0.09 | 0.05 | 0.98 |
| Buffer uploads | 0.44 | 0.35 | 0.80 |
| Clear, and the copy to RetroArch's framebuffer | 0.56 | 0.58 | 0.64 |
| The core's own code (and the timers) | 1.86 | 1.37 | 3.74 |

The draw calls are two thirds of the render; the state calls themselves are cheap (a bind or a
program change about 1.5 us, the rest under 0.3 us). What a draw costs depends on what changed
before it (us per draw, Crazy Taxi; NFL 2K2 where noted):

| Changed since the last draw | Before | With the vertex range |
| --- | ---: | ---: |
| Nothing | 3.6 | 3.4 |
| Blend, depth, cull or stencil only | 6.5 | 6.0 |
| Texture | 12.2 (NFL 2K2: 17 to 21) | 7.1 (NFL 2K2: 7.5) |
| Texture and its parameters | 12.4 | 6.6 |
| Program | 17.5 | 10.3 |
| Program and texture | 16.5 | 11.3 |

So the driver time follows, in this order: the number of indexed draws and their size (the index
scan, about 5 us a draw and more for long strips, gone with the range), program changes (about
5 us at the draw plus the call), texture changes (about 4 us plus the call), other state (about
2.5 us). A draw with nothing changed is 3.5 us.

What the lists hold (`prototypes/logs/*-sort-simulation.log`):

| Per render | Crazy Taxi | SA2 | NFL 2K2 |
| --- | ---: | ---: | ---: |
| Opaque polygons drawn / different states among them | 296 / 187 | 302 / 129 | 252 / 77 |
| Translucent polygons / states | 195 / 77 | 87 / 29 | 550 / 49 |
| Program changes by shader bit | Gouraud 192 of 220 | spread, 22 in all | trilinear and use-alpha, 30 to 115 each |

## 2. Options, ranked

| # | Option | Gain | Fidelity risk | Outcome |
| --- | --- | --- | --- | --- |
| 1 | Vertex range with every indexed draw | +24% Crazy Taxi, +13% SA2 (to the SH4 thread's limit), +11% NFL 2K2 | None: same triangles, same state, same order | Done (row 16) |
| 2 | One draw for a run of one-triangle modifier volumes (Deadcast) | NFL 2K2: with 1, 52% to 95% | None: the two draws of such a volume come down to one stencil write, and the writes commute | Done (row 15) |
| 2b | Batch any volumes that share no pixel (screen boxes on a grid) | NFL 2K2 with 1: 50% to 79% (about 200 draws left for the volumes, and 0.7 ms a frame to plan) | None by construction, but more to go wrong | Prototyped, measured, dropped for 2: simpler and faster. Would still help volumes of several triangles; none of the games here has many |
| 3 | Let translucent polygons that are apart on screen pass each other, then merge | Simulated: NFL 2K2 550 to 298 draws (about 3 ms of its 15), Crazy Taxi 195 to 140, SA2 87 to 48 | Each pixel still gets its polygons in the same order, but the draw order of translucent polygons changes | Counted only; a decision to take before building it |
| 4 | One program for flat and Gouraud polygons, chosen by a uniform | Crazy Taxi: 222 to 60 program changes, render -0.66 ms, but +1.2% fps in the bench and SA2 -1.3% (both inside the spread) | None measured (frames identical); two more varyings in every shader | Prototyped; not worth it |
| 5 | Move opaque polygons next to an earlier one with their state where that provably can't change a pixel | Simulated: 296 to 276 draws (Crazy Taxi), 302 to 266 (SA2), 252 to 215 (NFL 2K2) | None if the rule holds (screen boxes apart, or both plain depth-tested polygons with depth ranges apart) | Counted only; small |
| 6 | Sort opaque polygons by program and texture outright | Up to the state counts above: 187, 129, 77 draws | Real: equal-depth decals with GEQUAL, and a pixel line wherever two surfaces cross | Rejected |
| 7 | Merge adjacent draws with identical GL state at draw time | 19 of 553 draws, 11 of 416, 0: under 0.1 ms | None | Not worth building |
| 8 | Skip redundant uniform, texture parameter, stencil calls | Uniforms 0.05 ms a frame. Texture parameters 0.2 ms, and those are real changes (one texture used with two wrap or filter settings) | None | Nothing to gain; sampler objects could remove the texture parameter calls |
| 9 | Multi-draw, base vertex, uniform buffers | GLES 3.2 has no multi-draw in core, and there are no adjacent same-state draws to feed one (7). The common uniforms are 0.05 ms | None | Nothing to gain |
| 10 | Invalidate depth and stencil after the frame | NFL 2K2: no change | None | Tried, no effect |

What is left is the texture change itself (about 400 a frame in Crazy Taxi and SA2, 800 in
NFL 2K2, at 4 us in the draw plus 1.6 us for the bind). Only fewer binds help, which is options 3
and 5, or texture arrays (a redesign of the texture cache, with risk).

## 3. The change

**Vertex range.** `makePrimRestartIndex`, `makeIndex` and `sortTriangles` (`ta_util.cpp`) record
the lowest and highest vertex each polygon's indices name, merged neighbours included
(`PolyParam::vtxMin`, `vtxMax`; `SortedTriangle` the same). `DrawList` and `drawSorted` draw through
`drawElements` (`gldraw.cpp`), which passes the range to `glDrawRangeElements` on GL 3 / GLES 3 and
falls back to `glDrawElements`. libretro-common's glsm gets the wrapper it lacked.

**One-triangle volumes.** A modifier volume takes two draws: its triangles into stencil bit 1
(inverted or set where they pass the depth test), then the same triangles again to fold bit 1 into
bit 0 and clear it. For a volume of one triangle, closed by that triangle, the two come down to
bit 0 set (inclusion) or cleared (exclusion) where the triangle is in front, bit 1 left 0. Those
writes don't depend on order, so `DrawModVols` draws the run of such volumes with the same mode,
culling and tile clip, their triangles one after the other, in one call
(`IncludeTriangles` / `ExcludeTriangles` in `SetMVS_Mode`). Deadcast does this in its Vulkan
drawer and pipeline (`3e3b549579`); this is the same rule with GL stencil state. Not for Naomi 2's
volumes, which carry matrices of their own.

## 4. Measurements

Bench: `ARMS="fcr-dcbase fcr-prfinal" UNCAPPED=1 DRIVE=0 TAG=gl-draw-cost-final
flycastrophe/bench.sh 3 10 30` (`bench-uncapped/summary.md`); `fcr-dcbase` is `main`, `fcr-prfinal`
this branch (core sha256 `083bf660...`), both built by Flycastrophe-pak's `build-core.sh`.

| Arm | Crazy Taxi fps (rounds) | SA2 fps (rounds) | GPU load |
| --- | --- | --- | ---: |
| fcr-dcbase | 73.15 (72.8, 73.3, 73.4) | 99.90 (99.7, 103.0, 98.2) | 65%, 67% |
| fcr-prfinal | 90.74 (90.7, 91.8, 89.7), +24.0% | 112.92 (112.9, 112.8, 113.1), +13.0% | 79%, 75% |

RetroArch's thread stays the limit in Crazy Taxi (98%, the SH4 thread at 83%). In SA2 it drops to
83% and the SH4 thread is at 98%. A first run of the same renderer code two hours earlier gave
74.62 to 91.00 (+22.0%) and 100.77 to 112.91 (+12.0%).

Capped at 60 fps (`bench-capped/`, one round): both hold 60 fps; RetroArch's thread drops from 80%
to 63% of a core in Crazy Taxi and from 57% to 43% in SA2. (The summary's pass/fail lines flag
differences of a hundredth of a frame.)

NFL 2K2 (`nfl2k2/summary.txt`): `flycastrophe/perf-run.sh` from the saved play, 30 s, speed from the
perf lines after the first 3 s. The play gets heavier as it goes and the faster build gets further
into it; over the same 12 emulated seconds `main` runs at 55.8% both times, the branch at 97.2% and
97.7%. Render time per frame 30.7 ms to 15.4 ms, with the SH4 thread at 82% of a core.

The earlier prototype runs (range hints alone, the grid batching of option 2b, the shared
flat/Gouraud program, the invalidate) are in `prototypes/`: one build with the prototypes behind
environment bits, `prototypes/bench-uncapped/summary.md`, `prototypes/nfl2k2-ab-summary.txt`. That
build's counters cost it 2% against `main` with everything off; none of them is in this change.

## 5. Same picture

`FLYCASTROPHE_GLHASH=1` (new, with `FLYCASTROPHE_PERF=1`) reads each frame back right after its
polygons are drawn and logs a hash of the pixels beside a hash of what the frame was drawn from
(vertices, polygon and volume parameters, the data of the textures used, palette, fog and clamp
values). `flycastrophe/hashcmp.py` pairs two runs' frames by the second hash and compares the
first. Base: this branch's first commit (the check alone on `main`); new: the branch.

- **From the bench states and the NFL 2K2 play, both sorting modes** (`frame-check/states.txt`):
  Crazy Taxi 895 and 802 paired frames (per-strip, per-triangle), SA2 1,162 and 1,152, NFL 2K2 96
  and 90 (its play drifts apart after a few seconds). All identical.
- **25 games** (`frame-check/games.txt`, `device-checks/frame-check.sh`): booted from the BIOS with
  no input, 45 s on each build, threaded rendering off. 30,944 paired frames, none
  different, no control run needed. Dreamcast: Dead or Alive 2, Power Stone, Sega Rally 2, Daytona
  USA 2001, Spider-Man, Ecco, Armada, Sonic Adventure, Headhunter, Marvel vs. Capcom 2, Rez, Shenmue,
  Skies of Arcadia, Soulcalibur, Jet Set Radio, Virtua Tennis 2, Tony Hawk's Pro Skater 2, Virtua
  Fighter 3tb, Ikaruga. NAOMI: Capcom vs. SNK, Guilty Gear XX. NAOMI 2: Virtua Fighter 4. Atomiswave:
  Dolphin Blue, Fist of the North Star, Metal Slug 6. Soulcalibur (3,815 frames), Power Stone (3,369)
  and Dolphin Blue (2,197) get furthest into 3D attract modes; Daytona, Rez, Shenmue, Ikaruga and
  Marvel vs. Capcom 2 stop at a still screen after the boot animation (about 416 frames each).
- **The prototypes** (`prototypes/frame-hashes.txt`, an earlier hash without texture data):
  14,393 paired frames over 21 comparisons, all identical.

`screenshots/<game>-frame.jpg` is one emulated frame per scene, dumped
(`FLYCASTROPHE_GLDUMP=<hash>:<file>`) from the base and from the branch: the two raw dumps have the
same SHA-256 (`screenshots/sha256-raw-frames.txt`), so one image stands for both.

### What the check turned up in `main`

Two things made frames differ between two runs of the same build, before any of this change. The
check now steps around both; neither is fixed here.

- **A column of uninitialised texels beside videos.** A stride texture (a video narrower than its
  power-of-two texture) is decoded into a buffer that isn't cleared, the whole buffer is uploaded,
  and bilinear filtering at the video's right edge blends in the first column past it. Spider-Man's
  two intro videos show it in the last pixel column: about 430 of 1,050 frames differed between
  two runs of one build. With `FLYCASTROPHE_GLHASH` on the buffer is zeroed first, and the same two
  runs then agree on every frame.
- **Textures decoded while the emulation thread rewrites them.** With threaded rendering on, about
  1% of Headhunter's frames after its intro differ between two runs of one build (36 of 2,460),
  at scattered single frames; with it off, none of 1,525. The game check runs with it off.

## Not covered

- Hands-on play. The checks above are attract modes and three scenes; nobody has played a game
  through with this.
- The game check runs with threaded rendering off (see above). The state checks ran with it on.
- Naomi 2 volumes and volumes of several triangles are drawn as before. A game with many of the
  second kind would want option 2b.
- PGO: the profile fits the pinned commit, so a release with this needs a new one.
