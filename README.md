# Flycastrophe

Flycastrophe is a Sega Dreamcast, Naomi and Atomiswave emulator for the Miniloong Pocket 1,
made for [Leaf](https://leaf.game). It's [Flycast](https://github.com/flyinghead/flycast)'s
libretro core with the speed changes from
[Deadcast](https://github.com/tyrannotorus/emulator-dreamcast-deadcast) ported in, running in
Leaf's own RetroArch. The name is a warning: it trades some accuracy for speed, so a game that
looks wrong here may be fine in Flycast.

**Status: in development, not released yet.** Once it's published you install it on Leaf through
Pak Rat, and it shows up as an emulator you can pick for Dreamcast, Naomi and Atomiswave games.
[Flycastrophe-pak](https://github.com/Helaas/Flycastrophe-pak) builds that package from a pinned
commit of this repository.

## How fast it is

Measured on a Miniloong Pocket 1 (RK3566: four Cortex-A55 cores at 2 GHz, Mali-G52) in Leaf's
RetroArch, from the same savestates, against the two libretro Dreamcast cores Leaf ships:

| Scene | Leaf's Flycast | FlyCast Fast UMRK | Flycastrophe |
| --- | ---: | ---: | ---: |
| Crazy Taxi, as played | 58.5 fps | 35.0 fps | **60.0 fps** |
| Sonic Adventure 2, as played | 59.9 fps | 58.2 fps | **60.0 fps** |
| Crazy Taxi, no frame limit | 58.9 fps | 48.5 fps | **71.6 fps** |
| Sonic Adventure 2, no frame limit | 61.4 fps | - | **91.4 fps** |

"As played" means vsync and audio sync on. FlyCast Fast UMRK is a 2022 Flycast whose savestates
the newer cores can't load, so its Sonic Adventure 2 scene differs and isn't compared. The full
runs, frame times and audio underruns are in
[flycastrophe/evidence/phase3](flycastrophe/evidence/phase3/README.md).

## What's in it

- The sound chip (AICA) runs on a thread of its own, and so does the preparation of each
  frame's polygons.
- Deadcast's recompiler for the SH4: the whole memory map in one window, pinned registers,
  faster vector math, idle-loop skipping, and the MMU windows that Windows CE games need.
- A smaller vertex format, textures that aren't uploaded again when their data hasn't changed,
  and Deadcast's translucent-sorting fixes.
- A code cache on disk: the code a game ran is compiled again right after a state load, rather
  than during its first seconds.
- Frame skipping when a game falls behind, so it keeps full speed and clean sound.

Left out: Deadcast's Vulkan renderer work (Flycastrophe renders with GLES, which measured faster
here), and everything specific to Deadcast's own program and to the TrimUI Brick.
[FLYCASTROPHE.md](FLYCASTROPHE.md) lists every change, what was left out, and why.

## Options

Each speed change you might want to turn off has a core option, on by default:

| Option | What it does |
| --- | --- |
| Threaded Audio | Runs the sound chip on its own thread. Turn it off if a game's sound or timing goes wrong. |
| Parse Thread | Prepares each frame's polygons on its own thread. Helps games limited by drawing, costs a little in the rest. |
| Fast Vector Math | Computes the CPU's vector instructions faster but less exactly. Turn it off if a game's geometry jitters. |
| Idle Loop Skip | Skips the wait loops of the games Flycastrophe knows. Turn it off if a game hangs or runs at the wrong speed. |
| Auto Skip Frame | Set to Maximum: skips up to two frames in a row while a game is behind. |

Transparency sorting defaults to per-strip, and per-pixel sorting isn't available. With
`FLYCASTROPHE_PERF=1` in its environment, the core logs a line every second with its emulated
speed, thread loads and frame skips.

## Building

Flycastrophe is Flycast's libretro build with one extra switch:

```
cmake -S . -B build -DLIBRETRO=ON -DFLYCASTROPHE=ON -DUSE_GLES=ON -DUSE_VULKAN=OFF \
      -DUSE_OPENMP=OFF -DCMAKE_BUILD_TYPE=Release
cmake --build build --target flycast_libretro
```

`FLYCASTROPHE=ON` names the output `flycastrophe_libretro.so`, reports the library as
"Flycastrophe", turns the speed options on by default, keeps shared VMUs in
`<system>/dc/flycastrophe/`, and leaves out the per-pixel (GL4) renderer. The Miniloong Pocket 1
build, in the pinned toolchain image, and the package are in
[Flycastrophe-pak](https://github.com/Helaas/Flycastrophe-pak).

## This repository

- [FLYCASTROPHE.md](FLYCASTROPHE.md): the port ledger, every Deadcast change and its outcome.
- [flycastrophe/](flycastrophe/README.md): the plan, the measurements behind each change, and the
  bench and device-check scripts.
- `core/deadcast/`: Deadcast's own new files, as Deadcast names them. Changes to Flycast's own
  files are marked with `Deadcast:` comments where they come from Deadcast and `Flycastrophe:`
  where they don't. The `FLYCASTROPHE` switch sets the name, the defaults and the VMU folder.
- Everything else is Flycast. `main` follows Flycast's `master` by merge, through a pull request.

## Credits and licence

Flycast is by flyinghead and its contributors, and grew out of
[reicast](https://github.com/skmp/reicast-emulator). Deadcast, where the speed work comes from,
is by tyrannotorus. Any mistakes in the port are Flycastrophe's. Flycastrophe is GPL-2.0, like
Flycast: see [LICENSE](LICENSE). Flycast's own README, with its builds and documentation, is at
[flyinghead/flycast](https://github.com/flyinghead/flycast#readme).
