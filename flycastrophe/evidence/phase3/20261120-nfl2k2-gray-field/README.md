# NFL 2K2: gray field at grass stadiums (2026-11-20)

Reported on the 0.3.0 test build: the grass turns gray in the cutscene before the match.

**Result: not new in 0.3.0.** With the Cardinals at home the field is gray in close-ups and streaked gray in some
wide views on every core tried, all with the same key sequence (cutscenes skipped with A):

| Core | Close-ups | Wide views | Picture |
| --- | --- | --- | --- |
| 0.3.0 test core (3ae7f022) | gray | gray streaks and patches | `cards-030.jpg` |
| 0.2.0 release core (db68e7da) | gray | thin gray lines | `cards-020.jpg` |
| 0.3.0 test core, Fast Vector Math off | gray | gray streaks | `cards-030-fastmath-off.jpg` |
| Leaf's own Flycast (upstream) | none captured | gray bands across the field | `cards-stock.jpg` |

`cardinals-0.2.0-left-0.3.0-right.jpg` puts two close-ups from each build side by side.

- **It depends on the stadium.** Broncos at home showed it too (`skip-030b.jpg`, 0.3.0 only). Giants, Vikings,
  Eagles, Cowboys and Panthers home games were green on the builds tried (`boot-030.jpg`, `boot-020.jpg`,
  `skip-020.jpg`).
- **One state, two cores.** A savestate from the reporting session, at the coin toss, shows the same picture on
  0.2.0 and 0.3.0 (`coin-toss-state-0.2.0-left-0.3.0-right.jpg`): the gray patch measures RGB 127/129/124 against
  128/130/123, the grass 97/123/85 on both. The gray patch there is the sideline.
- **Options.** Group Translucent Polygons was off in the session captured (`live-capture.jpg`), and the saved
  play looks the same with it off and on (`saved-play-0.2.0-0.3.0-off-0.3.0-on.jpg`: rows are 0.2.0, 0.3.0 off,
  0.3.0 on).

**Not known:** the cause. The pictures look like two field layers at the same depth, with green showing through
seams and streaks; nobody has looked at the draw data. One pre-snap pair showed more gray on 0.3.0 than on
0.2.0, but the two games had different visitors and camera positions, so it says nothing either way.

**Frame check** (`frame-check.txt`): `main` against the PGO-trained core pairs 0 of about 1,450 frames, with the
option off and on. The trained build's frame data never matches a build without a profile, so this check
cannot compare a trained core with anything else. Cause not looked into.

Recipe: `tools/nfl-start.sh` boots the game and leaves it running. At Team Select push the stick right, cycle
the home team with the triggers (alphabetical by nickname, then alumni and all-star teams), stick left to give
the pad back, START, START, then A to skip. The matchup is random per boot, so read the home team from a
screenshot first. The D-pad does nothing in this game's menus. `tools/grass.sh` measures the field's colour; a
downscaled contact sheet is not a measurement. The savestate and the raw screenshots stay out of the repository.
