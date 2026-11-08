# Phase 0 tooling (archived)

Copied from the local, never-pushed `Flycastrophe-pak` skeleton when the project switched to
GLES (2026-11-07). Paths inside the scripts still assume that skeleton's layout
(`tools/<name>/`, `patches/retroarch/{leaf,pak}/`, `build/`).

- `vkprobe/`: Vulkan + Wayland probe (`vkprobe.c`) and its build in the mlp1-toolchain image.
- `wsi-layer/`: build of Arm's vulkan-wsi-layer (ginkage `40cfec09`) with Wayland, renamed to
  `VK_LAYER_flycastrophe_wsi`, plus the xcb/Xlib stub headers it needs.
- `retroarch/`: the Vulkan RetroArch build (v1.22.2 + Leaf's 10 patches + the 2 pak patches in
  `patches-pak/`). Leaf's patches are not copied: `leaf-patches-SOURCE.json` names the
  retroarch-builds commit and the sha256 of each.
- `phase0-bench/`: the GLES vs Vulkan bench runner and summarizer as they were for Phase 0. The
  live, generalized copy is `tmp/dc-core-bench/flycastrophe/` (any RetroArch + core arms).
