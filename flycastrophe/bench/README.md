# Bench and device checks

A snapshot (2026-11-08) of the scripts behind [the evidence](../evidence/). They ran from the UMRK
workspace's bench folder, `tmp/dc-core-bench`, which is what the evidence READMEs call it; that
folder also holds the data this repository leaves out (below). The layout here matches it, so the
scripts' relative references still line up.

## What runs where

The host is a Mac with `adb`; the device is a Miniloong Pocket 1 with Leaf. Each run copies a core
to `/userdata/dc-core-bench/cores`, writes a Leaf-like `retroarch.cfg` there, pauses Leaf's
launcher, starts Leaf's own RetroArch on a game with a savestate, samples it over RetroArch's
command port (`GET_PERF_INFO`), takes screenshots, and puts the launcher back. Audio is on:
`write_ra_cfg` sets `audio_mute_enable = "false"` (the "muted" note in `lib-bench.sh`'s header
predates that).

| File | Use |
| --- | --- |
| `lib-bench.sh` | Shared helpers: device paths, arms to core files, savestate families, the RetroArch config, launcher pause and resume, screenshots. `core-options-arm-<arm>.cfg` gives one arm its own core options. |
| `flycastrophe/bench.sh` | The bench: `ARMS="a b" [UNCAPPED=1] [REPLAY=1] [TAG=x] flycastrophe/bench.sh ROUNDS WARMUP SECONDS`. Interleaves the arms each round, cools the SoC between runs, writes a suite folder and its summary. `STATE_FAMILY` loads another generation's savestates. |
| `flycastrophe/summarize.py` | The suite summary: fps median/p5/min from frame-counter deltas, frame-time p95, underruns, per-thread CPU, each arm against the first. |
| `flycastrophe/record-replay.sh` | Records a RetroArch input replay from a savestate. Replays diverge between cores under threaded rendering, so they're a secondary measure. |
| `verify_state.py` | Refuses a truncated savestate before a run. |
| `rapad.c`, `drive-loop.sh`, `drive-*.txt` | RetroArch's network gamepad (`rapad`, built static for aarch64) and the input scripts it loops for driving runs. |
| `core-options.cfg` | The bench's core options: threaded rendering, per-strip sorting, DSP off, 640x480, fast GD-ROM loading, auto frame skip off. |
| `core-options-fcrskip.cfg` | The same with Auto Skip Frame at Maximum (frame-skip tests). |
| `core-options-arm-fastumrk.cfg` | Leaf's shipped options for FlyCast Fast UMRK over the bench's. |
| `device-checks/boot-check.sh` | Boots a ROM on one or more arms, screenshots at set times. |
| `device-checks/checklist.sh` | The 17-game boot checklist: copies each game to the bench folder (or boots it in place with `CARD=1`), screenshots, QUIT, removes it. Needs `BIOS_DIR` for the arcade BIOS. |
| `device-checks/cache-check.sh` | Two runs of one game, stopped with QUIT or SIGTERM, to check the code cache's save and warm-up. |
| `device-checks/step.sh`, `daytona-check.sh`, `drive-daytona.txt` | Step through a game's menus one button at a time with a screenshot after each (Daytona USA 2001's decals). |
| `device-checks/vf4-check.sh` | Virtua Fighter 4 (Naomi 2) lighting check. |

The Pak Rat lifecycle script sits with its evidence:
[evidence/phase3/20261108-pakrat-lifecycle](../evidence/phase3/20261108-pakrat-lifecycle/).

## Not included

- **Savestates and replays** (`states/`, `replays/`, about 125 MB): snapshots of commercial games'
  memory, which don't belong in a public repository. Each is made from a game you own:
  `record-replay.sh` makes replays, and the states are RetroArch saves at the scene the evidence
  describes.
- **ROMs, BIOS and the cores under test** (`out/`).
- **Older UMRK bench scripts** in the same folder that Flycastrophe didn't use.
