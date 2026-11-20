# Per-polygon setup in the GLES renderer (2026-11-11)

What the renderer's own code costs per polygon on the MLP1 once the draws themselves are cheaper
(rows 15 and 16), and three small changes that take some of it away (ledger row 18). No GL call is
added, removed or reordered, so the picture cannot change; it was checked anyway. Dev builds without
PGO, base `1d7ef4ed`.

## Result

| | base (`1d7ef4ed`) | this change |
| --- | ---: | ---: |
| SA2 City Escape, capped, seconds with 1,000 draws or more: ms per render | 13.03 | 12.62 (-3.1%) |
| the same, render thread's CPU | 88.6% | 87.0% |
| the same, seconds with 700 draws or more: ms per render | 11.44 | 11.08 (-3.1%) |
| Crazy Taxi, uncapped still scene: ms per render | 8.96 | 8.58 (-4.2%) |
| Crazy Taxi, uncapped still scene: fps | 90.1 | 91.4 (+1.4%) |
| SA2, uncapped still scene: fps (limited by the SH4 thread) | 111.7 | 112.2 |

About 0.4 ms off a render where the renderer is the limit. It is a small gain: in City Escape the
two base runs are 12.81 and 13.24 ms and the two with the change 12.82 and 12.40, so one pair
overlaps, and Crazy Taxi's fps gain is inside the spread of its three rounds (89.7 to 91.1 against
89.1 to 93.1). The ms per render is lower in the mean of every scene.

`summary.txt` is `tools/trimsum.py` over `speed/` (two interleaved rounds, the Hero story's opening
from a state, 107 s, capped, performance governors, frame skip off) and `speed-uncapped/` (three
interleaved rounds of the two bench scenes, 30 s each).

## 1. Where the render thread's time goes

Deadcast's profiler (`DEADCAST_PROF`, 1 ms samples of CPU time) on the base build, the render
thread over City Escape's heaviest 20 s, 4,880 samples (`profile/render-thread-67-87s.txt`, made by
`tools/profwin.py`):

| | Share |
| --- | ---: |
| Mali, called from the polygon loop (`DrawStrips`, `DrawList`) | 45.6% |
| Mali, from the rest of `Render` (uploads, the copy to RetroArch's framebuffer) | 10.1% |
| Mali and RetroArch, presenting (from `retro_run`) | 8.0% |
| The core's own code | 18.1% |
| of it `DrawList`, opaque | 9.6% |
| of it `SetTextureRepeatMode` and the texture parameter map | 3.6% |
| of it `GetProgram` | 1.1% |

Inside `DrawList`, 3.8% of the thread's time sits on the one instruction at the top of the loop
that first reads a polygon's record: a cache miss per polygon, over about 1,000 polygons a frame.

## 2. The changes

- **Texture parameters looked up once per bind.** The GL state cache keeps each texture's filter and
  wrap values in a `std::map` and searched it for every parameter of every polygon. It now keeps a
  pointer to the bound texture's entry, found on the first parameter after a bind and dropped when
  the binding changes, a texture is deleted or the cache is reset.
- **The next polygon prefetched.** The loop asks for the polygon record two ahead and for the
  texture record of the next polygon while the current draw is in the driver.
- **`GetProgram` remembers its last result.** Most polygons use the program of the one before, so
  the same key returns the same shader without the hash lookup. The slow path still runs when the
  shader isn't compiled yet or its per-frame uniforms are stale, and the memory is cleared with the
  shader table.

## 3. Same picture

`device-checks/frame-check.sh` (row 16's check): each frame's pixels hashed beside a hash of what
the frame was drawn from, frames paired between the base and the changed build by the second hash,
threaded rendering off.

| | Paired frames | Different |
| --- | ---: | ---: |
| Three states: Crazy Taxi, SA2, SA2 City Escape (`frame-check/states.txt`) | 15,384 | 0 |
| 15 games booted with no input, 45 s (`frame-check/games.txt`) | 18,724 | 0 |
| 10 more Dreamcast games, the same way (`frame-check/nas.txt`) | 11,787 | 1, not from this change |

The one pair is in Virtua Tennis 2. In that run of the changed build one input hash
(`d5e129b267ad327c`) occurs twice with two pictures; the first is the picture the other three runs
have for it (two of the base, a second of the changed build). The second run of the changed build
agrees with both base runs on all 1,848 paired frames, and the two runs of the changed build differ
from each other on that same pair, so the picture of that frame depends on something the input
hash doesn't cover. Not looked into.

Games: Dead or Alive 2, Power Stone, Sega Rally 2, Daytona USA 2001, Spider-Man, Ecco, Armada,
Sonic Adventure, Headhunter, Capcom vs. SNK, Guilty Gear XX, Dolphin Blue, Fist of the North Star,
Metal Slug 6, Virtua Fighter 4; then Marvel vs. Capcom 2, Rez, Shenmue, Skies of Arcadia,
Soulcalibur, Jet Set Radio, Virtua Tennis 2, Tony Hawk's Pro Skater 2, Virtua Fighter 3tb, Ikaruga.
