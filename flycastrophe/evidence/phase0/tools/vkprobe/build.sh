#!/usr/bin/env bash
# Build vkprobe for the MLP1 in the pinned toolchain image.
# Output: build/vkprobe/vkprobe
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
IMG=ghcr.io/utility-muffin-research-kitchen/mlp1-toolchain@sha256:66aac16fb8b07e663c9b4d66970f272df195a6eba98dfad8286eabbaa617faf9
VK_HEADERS_URL=https://github.com/KhronosGroup/Vulkan-Headers.git
VK_HEADERS_COMMIT=2cd90f9d20df57eac214c148f3aed885372ddcfe # v1.4.321
OUT="$ROOT/build/vkprobe"
mkdir -p "$OUT"

if [[ ! -f "$ROOT/build/vulkan-headers/include/vulkan/vulkan.h" ]]; then
    rm -rf "$ROOT/build/vulkan-headers"
    git init -q "$ROOT/build/vulkan-headers"
    git -C "$ROOT/build/vulkan-headers" fetch -q --depth 1 "$VK_HEADERS_URL" "$VK_HEADERS_COMMIT"
    git -C "$ROOT/build/vulkan-headers" checkout -q FETCH_HEAD
fi

docker run --rm --platform linux/amd64 \
    -v "$ROOT/tools/vkprobe:/src:ro" \
    -v "$ROOT/build/vulkan-headers/include:/vkinc:ro" \
    -v "$OUT:/out" \
    "$IMG" sh -euc '
        TC=/opt/mlp1-toolchain/bin/aarch64-buildroot-linux-gnu
        S=$($TC-gcc -print-sysroot)
        X=$S/usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml
        wayland-scanner client-header "$X" /out/xdg-shell-client-protocol.h
        wayland-scanner private-code "$X" /out/xdg-shell-protocol.c
        $TC-gcc -O2 -Wall -Wextra -Wno-unused-parameter -I/vkinc -I/out \
            /src/vkprobe.c /out/xdg-shell-protocol.c -o /out/vkprobe \
            -lwayland-client -ldl
        $TC-strip /out/vkprobe
        $TC-readelf -d /out/vkprobe | grep NEEDED
    '
ls -l "$OUT/vkprobe"
