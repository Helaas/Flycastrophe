# Flycastrophe Phase 3: release bar (2026-11-08)

Flycastrophe at fork `main` `115dd9d` (`fcr-rel`, sha256 `ded6a8b8…`, development build of the
pinned toolchain) against the two libretro Dreamcast cores Leaf ships for MLP1:

| Arm | Core | Source | Options |
| --- | --- | --- | --- |
| `gles` | Leaf's `flycast` (`flycast_libretro.so`, sha256 `6ac785f8…`) | upstream Flycast `c3763d8` (2026) | bench profile (`core-options.cfg`): threaded rendering, per-strip sorting, DSP off, 640x480, fast GD-ROM loading, auto frame skip off |
| `fastumrk` | Leaf's `flycast_fast_umrk` (pulled from the card, sha256 `5061855f…`) | Flycast `4c293f3` (2022) + three patches + PGO | Leaf's shipped `FlyCast Fast UMRK.opt` over the bench profile (`core-options-arm-fastumrk.cfg`: adds synchronous rendering off) |
| `fcr-rel` | Flycastrophe | this fork | bench profile; Flycastrophe's own options at their defaults |

Leaf's RetroArch, MLP1 `b1622a9e81b735ad`, governors on `performance`, still scenes (no input),
audio on. Runner: `tmp/dc-core-bench/flycastrophe/bench.sh` (unversioned). The 2022 core needs its own
savestates (`xtreme-*.state`); the 2026 cores refuse them ("Unsupported version",
`20261108-123550-xstate-smoke/`), so its scenes can't be shared.

## Scenes

- **Crazy Taxi: same scene** for all three (`scenes/crazy-taxi-*-end.jpg`: same street and taxi;
  the count-down game clock at the end of round 1 reads 8'10" for FlyCast Fast UMRK and 8'42" for
  Flycastrophe, the same scene at a different point in time).
- **SA2: not the same scene.** The 2022 state has Sonic up against the stairs with the camera
  close in (`scenes/sa2-fastumrk-*.jpg`); the 2026 state shows the whole courtyard
  (`scenes/sa2-fcr-rel-*.jpg`). The 2022 core's frames are real (game time advanced 67.5 s vs
  58.5 s over the window, the same 1.15x as the fps), but on a lighter view. Uncapped SA2 against
  `fastumrk` is not a comparison.

## Results

Uncapped (vsync and audio sync off), 3 interleaved rounds, 10 s warm-up + 30 s
(`20261108-120534-releasebar-uncapped/`):

| Game | Leaf's Flycast | FlyCast Fast UMRK | Flycastrophe |
| --- | ---: | ---: | ---: |
| Crazy Taxi | 58.94 fps (p5 56.85) | 48.46 (p5 48.04) | **71.57** (p5 69.39): +21.4% / +47.7% |
| SA2 | 61.38 (p5 59.82) | 103.27 (other scene) | **91.38** (p5 90.53): +48.9% vs Leaf's Flycast |

Capped (vsync and audio sync on, as played), 2 rounds (`20261108-122330-releasebar-capped/`):

| Game | Leaf's Flycast | FlyCast Fast UMRK | Flycastrophe |
| --- | --- | --- | --- |
| Crazy Taxi | 58.46 fps, p95 18.8 ms, underruns 12.6% | 35.01 fps, p95 42.5 ms, 0.1%, 969 dropped | **60.00 fps, p95 17.2 ms, 0.5%** |
| SA2 | 59.92 fps, p95 17.5 ms, 3.6% | 58.15 fps, p95 33.4 ms, 0.2%, 403 dropped | **60.04 fps, p95 17.4 ms, 0.3%** |

- Leaf's Flycast is limited by its SH4 thread (`Flycast-emu` 97-99% of a core); Flycastrophe's
  runs at 61-64% capped.
- FlyCast Fast UMRK keeps its audio full (0.1-0.2% underruns) by showing fewer frames: with
  synchronous rendering off its game runs at speed while it presents 35 (Crazy Taxi) or 58 (SA2)
  frames a second.
- Startup (process start to first command reply, including the state load) is 0.3-0.5 s longer for
  Flycastrophe (1.40-1.81 s vs 1.13-1.36 s): the code cache compiles the recorded blocks during the
  state load (5902 blocks in ~300 ms on Crazy Taxi, 7742 in 423 ms on SA2, from the `.blocks` files
  of the earlier QUIT runs).

**Verdict:** with audio on (the bar's measure) Flycastrophe is at or above both cores on both
games, with the lowest frame-time p95; uncapped it is faster than both on Crazy Taxi and faster
than Leaf's Flycast on SA2. The uncapped SA2 comparison with FlyCast Fast UMRK stays open (no
shared scene).

## Play checklist (boot level)

Each game booted on `fcr-rel` with no input; frames at 30, 60 and 100 s; QUIT over the command
port (`20261108-checklist/`, `checklist.sh`). Dreamcast games were copied to the bench folder one at
a time and removed after; the arcade games and Headhunter ran in place from the card (their
settings went to the bench's `saves/reicast/`, nothing written next to them).

| Game | Result at 100 s |
| --- | --- |
| Crazy Taxi, SA2 | the bench runs above |
| Sega Rally 2 (Windows CE) | attract loop (ranking) |
| Dead or Alive 2 (USA) | VMU prompt "press Start to create a game data file" |
| Marvel vs. Capcom 2 (USA) | memory card prompt (needs Start) |
| Power Stone (USA) | in-game attract |
| Rez (Europe) | "New file created", auto-save on |
| Shenmue (Europe, disc 1) | 50/60 Hz TV setting prompt |
| Skies of Arcadia (Europe, disc 1) | intro cinematic |
| Daytona USA 2001 (Europe) | memory card selection (decals checked in #9) |
| Headhunter (Europe, m3u) | intro video |
| NAOMI: Capcom vs. SNK | attract (ranking) |
| NAOMI: Guilty Gear XX (GD-ROM) | first-boot "EEPROM ID or Version Err", then "BACKUPRAM ID Err" (blank settings); after Start at both: title, demo fight, ranking |
| NAOMI 2: Virtua Fighter 4 | attract fight |
| Atomiswave: Dolphin Blue, Fist of the North Star, Metal Slug 6 | attract loops |

Every game exited cleanly after QUIT. New Dreamcast saves landed in
`system/dc/flycastrophe/vmu_save_A1.bin`. Not covered here (hands-on): 10 minutes of play per game,
a state round trip per game, toggling each Flycastrophe option per game.

## Pak Rat device pass (2026-11-08)

Flycastrophe-pak `020ce56` (core `4a22ad60…`) installed through Pak Rat's own store code
(`jawaka-pakrat-smoke` built from Jawaka main `1a57285`) from a local feed served through
`adb reverse`, with jawakad bracketing each change (`20261108-pakrat-lifecycle/`,
`flycastrophe-pakrat-lifecycle.sh`, adapted from Leaf's `scripts/adb-dsperate-lifecycle.sh`):

- **Install:** `Apps/mlp1/Flycastrophe.pak` with the core (sha256 as locked), info file and
  licences, no `launch.sh` and no Apps entry; ownership row `0.1.0`; the effective catalog gains
  the `flycastrophe` core and lists it after the shipped cores for DC, NAOMI and ATOMISWAVE.
- **Reinstall** of the same version: no change.
- **Per-system choice:** DC set to `flycastrophe` survives a rescan.
- **Installed core:** Leaf's RetroArch with the bench config (no RetroAchievements login) loads the
  installed file, runs Crazy Taxi from its state and quits cleanly.
- **Uninstall:** pak folder, ownership row and picker entries gone, the catalog back at the release
  generation; the saved DC choice is kept and falls back to Leaf's default (`flycast_standalone`).
- Left installed from the feed for hands-on play; dev-catalog-url, the DC choice, the helper and
  the tunnel restored to how they were found.

Not done here: a launch through Leaf's launcher (it signs in to RetroAchievements, and the test
games may have sets).
