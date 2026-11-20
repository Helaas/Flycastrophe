# Translucent polygons that share no pixel pass each other (2026-11-19)

Issue #32, ledger row 19. Behind `reicast_fcr_translucent_regroup` ("Group Translucent Polygons"),
off by default. Dev builds without PGO on one MLP1, base `1d7ef4ed`, two rounds with the arm order
swapped in the second.

## Result

| | base | regroup |
| --- | ---: | ---: |
| NFL 2K2, 2-14 s of the saved play, speed | 95.6% / 94.8% | 107.1% / 107.4% |
| NFL 2K2 draws, ms per render | 789, 15.3 ms | 555, 13.2 ms |
| Crazy Taxi, uncapped still scene, fps | 90.1 / 90.9 | 93.2 / 95.7 |
| Crazy Taxi draws, ms per render | 555, 8.9 ms | 503, 8.2 ms |

SA2 was measured with the first version only (`ae437faa`, which was not exact, see below):
uncapped still scene 111.1 / 113.1 to 113.3 / 113.4 fps, within the spread, since the SH4 thread is
the limit there (98-99% of a core). City Escape (55-90 s from `sa2-hero-intro.state`) 72.8 / 73.9 to
72.9 / 74.6 fps: it draws 80 translucent polygons a frame, and 30-40 draws come off. Its cost is in
the opaque list. `summary.txt` has every figure; `tools/span.py` makes them from the logs.

## What it does

On the parse thread, before the translucent index is built, a polygon moves back to join an
earlier polygon drawn the same way (`equivalentIgnoreCullingDirection`) when its screen box is at
least 1 pixel apart from the box of every group it passes, so `makePrimRestartIndex` merges them
into one draw. The search goes back at most 64 groups. A pixel's polygons stay in the game's order,
so blending gives the same result.

Three rules keep it exact:

- **Runs the index builder merges anyway move as units.** Merging a culled polygon into one of the
  other cull direction repeats a vertex, which turns its strip around and moves the edge ties
  between its own triangles. The first version reordered single polygons: Dead or Alive 2 (107
  frames) and Power Stone (7) showed single pixels off by one.
- **A group is joined only by a unit whose first polygon has the same cull mode** (or no culling),
  and the builder then merges along the groups as told.
- **A run of Naomi 2 polygons stays one unit, fixed in place.** Splitting them changed frames in
  Virtua Fighter 4 (64).

Covered: Per-Strip sorting and the translucent lists a game presorts. Per-Triangle sorting builds its
own index in `sortTriangles` and is unchanged. Only with primitive restart (GLES 3).

## Same picture

`device-checks/frame-check.sh` method over the 29 scenes of the opaque-sort prototype (24 games booted
from the BIOS with no input, 5 savestates), threaded rendering off, a control run of the base:
**28 pairable scenes, 33,842 paired frames, none different** (`frame-check/frame-check.txt`, arms
`tr3` and, for Virtua Fighter 4, `tr4`; `tr` and `tr2` are the earlier cuts). Armada's runs never
pair, even base against base. The frame check's input hash now hashes each polygon list as a set,
so a reordered list still pairs with the base (`fbb7e04c`).

## Not checked

- Speed in other games that draw many translucent polygons apart on screen.
- With the parse thread off (the code path is the same; no run).
- A run of this exact build (`1baa8889`) for speed: the speed rows are from `f969cbe2`, which differs
  only for Naomi 2.
