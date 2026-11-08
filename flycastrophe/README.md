# Flycastrophe working files

The plan, the measurements behind every change, and the scripts that took them. Moved here from
the UMRK workspace on 2026-11-08, so the project's records live with its code.

- [plan.md](plan.md): the plan and its decisions, with the current status at the top.
- [evidence/](evidence/): one folder per phase, each with a README of what was measured, how,
  and what it showed. Raw runs keep each run's metadata, samples and CPU snapshots; frames are
  kept where they back a correctness claim.
  - [phase0](evidence/phase0/README.md): the Vulkan gate. Vulkan through Leaf's Weston measured
    1-2% slower than GLES with the stock core, so Flycastrophe renders with GLES.
  - [phase1](evidence/phase1/): the bootstrap build against the stock core.
  - [phase2](evidence/phase2/README.md): the Deadcast ports, one row per pull request, with the
    bench method, the frame-skip investigation and correctness checks.
  - [phase3](evidence/phase3/README.md): the release bar against Leaf's two libretro Dreamcast
    cores, the boot checklist of 17 games, and the Pak Rat install pass.
- [bench/](bench/README.md): the bench harness and device-check scripts, as used.

Flycastrophe is developed against one Miniloong Pocket 1 with Leaf installed. Paths in these
files (`/Volumes/Storage/UMRK/...`, `/userdata/dc-core-bench`, `/mnt/sdcard`) are that setup's.
