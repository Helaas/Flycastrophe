# Opaque polygons sorted by state on the parse thread (2026-11-19)

The follow-up to the draw-time prototype of 2026-11-11 (`agent/opaque-sort`, `d0626cb1`). Code on
the branch `agent/opsort-parse` (`bf9e4d53`), not merged: it is not exact, so whether to take it is
open. Behind `reicast_fcr_opaque_state_sort` ("Group Opaque Polygons"), off by default. Dev builds
without PGO on one MLP1, base `1d7ef4ed`, two rounds with the arm order swapped in the second.

## Result

| | base | draw-time prototype | parse-time sort |
| --- | ---: | ---: | ---: |
| City Escape, uncapped (55-90 s from `sa2-hero-intro.state`), fps | 74.2 / 74.0 | 82.4 / 81.5 | **89.8 / 89.7** |
| City Escape draws / binds / ms per render | 861 / 761 / 11.4 | 863 / 197 / 9.7 | **311** / 255 / 7.3 |
| City Escape capped: ms per render, render thread | 10.6, 76% | 9.0, 66% | 6.0, 49% |
| Crazy Taxi, uncapped still scene, fps | 89.8 / 90.7 | 93.4 / 93.3 | **98.0 / 98.7** |
| Crazy Taxi draws / binds / ms per render | 555 / 411 / 8.9 | 555 / 299 / 8.4 | 452 / 342 / 7.6 |
| NFL 2K2, 2-14 s of the saved play, speed | 97.9 / 97.7% | 97.5 / 98.4% | **104.7 / 102.2%** |

The prototype's figures and the capped run are from `speed-first-version/` (same base, same day);
the final build's own runs are in `speed/`. `summary.txt` has every figure.

The projection before the work was about 230 draws and roughly 3 ms off City Escape's render. The
measured result is 311 draws and 4.1 ms off. City Escape's render thread is no longer the limit:
the SH4 thread is at 96% of a core.

## What it does

On the parse thread, before `makePrimRestartIndex`, the opaque list of each render pass is
stable-sorted by state, so the index builder merges neighbours that now share it. The prototype's
rule decides which polygons may move: depth test GREATER or GEQUAL, depth write on, no blending, not
Naomi 2, in an unbroken run inside one render pass. The key order is the prototype's: shader program
bits, texture, TSP, ISP (cull direction included) and tile clip. Within a program, groups keep the
order in which the game first draws each.

- **Runs the index builder would merge anyway move as units**, and the builder merges only along the
  joins the sort gives it. Merging a culled polygon into one of the other cull direction repeats a
  vertex, which turns its strip around and moves its depth by a rounding step; equal-depth layers then
  swap winners. The first version (`73b8529b`) did this: 1.3% of a Crazy Taxi frame's pixels, across
  the road. With units, that frame differs in 0 pixels.
- **Punch-through sorting** was tried (`onpt` arms) and saved no draws (City Escape 313 vs 311), so
  it was dropped (`a970c5f6`).
- Works with the parse thread on and off: the speed runs had it on, the frame check off.

## Picture

Frame check over the prototype's 29 scenes, threaded rendering off, with a control run of the base
(`frame-check/frame-check.txt`, arm `op4`). **7 of 28 pairable scenes show differing frames, 483 of
about 34,000:**

| Scene | differing / paired |
| --- | ---: |
| Crazy Taxi | 3 / 8 |
| SA2 City Escape | 61 / 2,961 |
| Dead or Alive 2 | 251 / 1,685 |
| NFL 2K2 | 7 / 85 |
| Skies of Arcadia | 24 / 1,500 |
| Virtua Tennis 2 | 8 / 1,894 |
| Virtua Fighter 3tb | 129 / 669 |

The first version (`op`) differed in 10 scenes and 1,522 frames. One differing City Escape frame,
dumped (`tools/pixdump.sh`, `tools/pixdiff.py`), differs in 1 pixel. The differences are surfaces
that share a depth, whose order the game's drawing order decided. Armada's runs never pair, even base
against base. The frame check's input hash hashes each polygon list as a set, so a reordered list
still pairs with the base (`78e6eafa`).

## Not checked

- Combined with the translucent regroup (#36): not built or measured together.
- How the differing frames look in play: only one frame was dumped per scene checked.
