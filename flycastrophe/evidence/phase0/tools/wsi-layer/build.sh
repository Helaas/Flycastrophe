#!/usr/bin/env bash
# Build Arm's vulkan-wsi-layer with its Wayland backend for the MLP1.
#
# Recipe follows ROCKNIX's RK3566 package (projects/ROCKNIX/packages/graphics/
# vulkan-wsi-layer/package.mk): ginkage fork, Wayland only, dma-buf heap
# allocator, FIFO presentation thread. The manifest is renamed to
# VK_LAYER_flycastrophe_wsi so it never collides with the system's Wayland-less
# VK_LAYER_window_system_integration; load it as an explicit layer
# as an implicit layer (see the manifest step below) with DISABLE_WSI_LAYER=1.
#
# Usage: tools/wsi-layer/build.sh [heap-name]   (default: system)
# Output: build/wsi-layer/<heap>/{libVkLayer_window_system_integration.so,
#                                 VkLayer_flycastrophe_wsi.json}
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
HEAP=${1:-system}
IMG=ghcr.io/utility-muffin-research-kitchen/mlp1-toolchain@sha256:66aac16fb8b07e663c9b4d66970f272df195a6eba98dfad8286eabbaa617faf9
WSI_URL=https://github.com/ginkage/vulkan-wsi-layer.git
WSI_COMMIT=40cfec09d0e2d42c5e1f2642cf4cba11e7008112
VKH_URL=https://github.com/KhronosGroup/Vulkan-Headers.git
VKH_COMMIT=8d6039a455a7ecc7d2a592ff97f62db4e59b70bf # v1.4.356, the layer's validated version
LAYER_NAME=VK_LAYER_flycastrophe_wsi

fetch() { # dir url commit
    if [[ "$(git -C "$1" rev-parse HEAD 2>/dev/null || true)" != "$3" ]]; then
        rm -rf "$1"
        git init -q "$1"
        git -C "$1" fetch -q --depth 1 "$2" "$3"
        git -C "$1" checkout -q FETCH_HEAD
    fi
}
fetch "$ROOT/build/src/vulkan-wsi-layer" "$WSI_URL" "$WSI_COMMIT"
fetch "$ROOT/build/src/vulkan-headers-1.4.356" "$VKH_URL" "$VKH_COMMIT"

OUT="$ROOT/build/wsi-layer/$HEAP"
rm -rf "$OUT"
mkdir -p "$OUT"

docker run --rm --platform linux/amd64 \
    -v "$ROOT/build/src/vulkan-wsi-layer:/src:ro" \
    -v "$ROOT/build/src/vulkan-headers-1.4.356/include:/vkinc:ro" \
    -v "$ROOT/tools/wsi-layer/stub-include:/stubinc:ro" \
    -v "$OUT:/out" \
    -e HEAP="$HEAP" \
    "$IMG" bash -euc '
        TC=/opt/mlp1-toolchain/bin/aarch64-buildroot-linux-gnu
        SYSROOT=$($TC-gcc -print-sysroot)
        export PKG_CONFIG_SYSROOT_DIR=$SYSROOT
        export PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/share/pkgconfig
        export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR
        cmake -S /src -B /tmp/b -G Ninja \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
            -DCMAKE_SYSROOT=$SYSROOT \
            -DCMAKE_C_COMPILER=$TC-gcc -DCMAKE_CXX_COMPILER=$TC-g++ \
            -DCMAKE_CXX_FLAGS="-idirafter /stubinc" \
            -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
            -DPKG_CONFIG_EXECUTABLE=/opt/mlp1-toolchain/bin/pkg-config \
            -DWAYLAND_SCANNER_EXEC=/opt/mlp1-toolchain/bin/wayland-scanner \
            -DVULKAN_CXX_INCLUDE=/vkinc \
            -DBUILD_WSI_HEADLESS=OFF -DBUILD_WSI_WAYLAND=ON \
            -DBUILD_WSI_DISPLAY=OFF -DBUILD_WSI_X11=OFF \
            -DSELECT_EXTERNAL_ALLOCATOR=dma_buf_heaps \
            -DWSIALLOC_MEMORY_HEAP_NAME=$HEAP \
            -DENABLE_WAYLAND_FIFO_PRESENTATION_THREAD=ON \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 >/tmp/cmake.log 2>&1 || { cat /tmp/cmake.log; exit 1; }
        ninja -C /tmp/b >/tmp/ninja.log 2>&1 || { tail -60 /tmp/ninja.log; exit 1; }
        grep -ciE "warning" /tmp/ninja.log | sed "s/^/compiler warnings: /"
        cp /tmp/b/libVkLayer_window_system_integration.so /tmp/b/VkLayer_window_system_integration.json /out/
        $TC-strip /out/libVkLayer_window_system_integration.so
        $TC-readelf -d /out/libVkLayer_window_system_integration.so | grep -E "NEEDED|RUNPATH"
    '

# Rename the layer and give it its own switches. It must be an implicit layer:
# the loader (1.3.207 on the MLP1) only lists an implicit layer's instance
# extensions in vkEnumerateInstanceExtensionProperties(NULL), which is where
# RetroArch looks for VK_KHR_wayland_surface. The pak wrapper exposes the
# manifest through XDG_DATA_DIRS (<dir>/vulkan/implicit_layer.d), sets
# FLYCASTROPHE_WSI=1 and DISABLE_WSI_LAYER=1 (the system copy).
python3 - "$OUT" "$LAYER_NAME" <<'PY'
import json, sys, pathlib
out, name = pathlib.Path(sys.argv[1]), sys.argv[2]
src = out / "VkLayer_window_system_integration.json"
m = json.loads(src.read_text())
m["layer"]["name"] = name
m["layer"]["library_path"] = "./libVkLayer_window_system_integration.so"
m["layer"]["description"] = "Arm WSI layer with Wayland (Flycastrophe build)"
m["layer"]["disable_environment"] = {"DISABLE_FLYCASTROPHE_WSI": "1"}
m["layer"]["enable_environment"] = {"FLYCASTROPHE_WSI": "1"}
(out / f"{name.replace('VK_LAYER_', 'VkLayer_')}.json").write_text(json.dumps(m, indent=4) + "\n")
src.unlink()
print("instance extensions:", [e["name"] for e in m["layer"]["instance_extensions"]])
PY
ls -l "$OUT"
