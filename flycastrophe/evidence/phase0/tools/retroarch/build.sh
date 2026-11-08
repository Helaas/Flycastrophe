#!/usr/bin/env bash
# Build the pak's own RetroArch: Leaf's MLP1 RetroArch v1.22.2 with Vulkan on
# Wayland instead of GLES through SDL.
#
# Same source, patch set and toolchain as Leaf's build (retroarch-builds
# build-mlp1.sh at the commit in patches/retroarch/leaf/SOURCE.json), then
# patches/retroarch/pak/. The configure line differs only where it must:
#   - RetroArch's own Wayland client and its Vulkan context present the
#     frames; SDL2 stays for the joypad driver only.
#   - No GL of any kind, no EGL. The Vulkan loader is dlopened at runtime
#     (libretro-common vulkan_symbol_wrapper), so configure's -lvulkan probe
#     is satisfied by a build-only stub that nothing links.
#   - slang, the built-in glslang and SPIRV-Cross are on: the Vulkan driver
#     needs them for its own menu and stock shaders.
#   - xkbcommon is absent from the sysroot, so Wayland keyboard input is off.
#     The pak has no keyboard.
#   - No FFmpeg: recording is out of scope for the pak.
#
# The binary links the device's own SDL2 2.28.5 from the rootfs. Leaf's
# patched copy only changes SDL's Wayland GLES swap, which this build never
# reaches.
#
# Usage: tools/retroarch/build.sh
#   RETROARCH_SEED=<git dir>   fetch the pinned commit from a local clone first
# Output: build/retroarch/{retroarch,build-info.txt}
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
IMG=ghcr.io/utility-muffin-research-kitchen/mlp1-toolchain@sha256:66aac16fb8b07e663c9b4d66970f272df195a6eba98dfad8286eabbaa617faf9
RA_URL=https://github.com/libretro/RetroArch.git
RA_COMMIT=69a4f0ea1e8aaf442ae4858f2e7f2b31a1776576 # v1.22.2
SRC="$ROOT/build/src/retroarch"
OUT="$ROOT/build/retroarch"

if [[ ! -d "$SRC/.git" ]]; then
    mkdir -p "$SRC"
    git -C "$SRC" init -q
    git -C "$SRC" remote add origin "$RA_URL"
fi
if ! git -C "$SRC" cat-file -e "$RA_COMMIT^{commit}" 2>/dev/null; then
    git -C "$SRC" fetch -q --depth 1 "${RETROARCH_SEED:-origin}" "$RA_COMMIT"
fi
git -C "$SRC" -c advice.detachedHead=false checkout -q --force "$RA_COMMIT"
git -C "$SRC" clean -q -fdx

# Leaf's set in SOURCE.json order, each checked against its recorded hash,
# then this pak's patches.
leaf_patches=$(python3 -I - "$ROOT/patches/retroarch/leaf" <<'PY'
import hashlib, json, pathlib, sys
d = pathlib.Path(sys.argv[1])
src = json.loads((d / "SOURCE.json").read_text())
for p in src["patches"]:
    f = d / p["file"]
    if hashlib.sha256(f.read_bytes()).hexdigest() != p["sha256"]:
        sys.exit(f"{f.name}: sha256 differs from SOURCE.json")
    print(f)
PY
)
while IFS= read -r patch; do
    git -C "$SRC" apply --whitespace=nowarn "$patch"
    echo "applied leaf/${patch##*/}"
done <<<"$leaf_patches"
for patch in "$ROOT"/patches/retroarch/pak/*.patch; do
    git -C "$SRC" apply --whitespace=nowarn "$patch"
    echo "applied pak/${patch##*/}"
done

rm -rf "$OUT"
mkdir -p "$OUT"

docker run --rm --platform linux/amd64 \
    -v "$SRC:/src:ro" \
    -v "$OUT:/out" \
    -e IMG="$IMG" \
    "$IMG" bash -euc '
        . /opt/mlp1-toolchain/umrk/mlp1-build-flags.env
        # Build on the container filesystem: faster than the macOS bind mount,
        # and case-sensitive.
        cp -a /src /tmp/ra
        cd /tmp/ra

        # configure probes -lvulkan for vkCreateInstance; RetroArch never links
        # it (Makefile.common adds no VULKAN_LIBS). The stub lives in the
        # throwaway container sysroot, and the NEEDED check below proves it.
        echo "void vkCreateInstance(void) {}" |
            $CROSS_TRIPLE-gcc -shared -fPIC -x c - -Wl,-soname,libvulkan.so.1 \
                -o "$SYSROOT/usr/lib/libvulkan.so"

        export CFLAGS="$UMRK_MLP1_PROFILE_CFLAGS -D_GNU_SOURCE"
        export CXXFLAGS="$UMRK_MLP1_PROFILE_CXXFLAGS -D_GNU_SOURCE"
        export LDFLAGS="$UMRK_MLP1_PROFILE_LDFLAGS"
        export PKG_CONF_PATH=pkg-config
        export PKG_CONFIG_SYSROOT_DIR=$SYSROOT
        export PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/share/pkgconfig
        export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR

        flags=(
            --host=$CROSS_TRIPLE
            --disable-qt --disable-discord --disable-x11
            --enable-wayland --disable-libdecor --disable-dbus
            --enable-pulse --disable-jack --disable-oss
            --enable-vulkan --disable-vulkan_display
            # glslang stays on auto: forcing it on makes configure demand the
            # system headers instead of falling back to the built-in copy.
            --enable-slang --enable-spirv_cross --enable-builtinglslang
            --disable-opengl --disable-opengl1 --disable-opengl_core
            --disable-opengles --disable-opengles3 --disable-egl
            --disable-kms --disable-mali_fbdev
            --enable-ssl --enable-networking --enable-command
            --enable-sdl2 --enable-alsa --disable-udev
            --enable-freetype --enable-zlib --disable-ffmpeg
        )
        ./configure "${flags[@]}" >/tmp/configure.log 2>&1 ||
            { tail -60 /tmp/configure.log; exit 1; }
        grep -E "^Checking presence of|^Notice|^Warning|Error" /tmp/configure.log |
            grep -iE "vulkan|wayland|slang|glslang|spirv|sdl2|pulse|xkb|egl|opengl|notice|warning|error" || true
        for want in HAVE_VULKAN HAVE_WAYLAND HAVE_SLANG HAVE_GLSLANG HAVE_SPIRV_CROSS HAVE_SDL2 HAVE_COMMAND; do
            grep -qx "$want = 1" config.mk || { echo "configure: $want is not 1" >&2; exit 1; }
        done
        for unwanted in HAVE_OPENGL HAVE_OPENGLES HAVE_EGL HAVE_X11 HAVE_FFMPEG; do
            if grep -qx "$unwanted = 1" config.mk; then echo "configure: $unwanted is on" >&2; exit 1; fi
        done

        make -j"$(nproc)" >/tmp/make.log 2>&1 || { grep -nE "error|Error" /tmp/make.log | head -40; tail -40 /tmp/make.log; exit 1; }
        echo "compiler warnings: $(grep -c "warning:" /tmp/make.log || true)"

        cp retroarch /out/retroarch
        $STRIP -s /out/retroarch
        needed=$($CROSS_TRIPLE-readelf -d /out/retroarch | sed -n "s/.*(NEEDED).*\[\(.*\)\]/\1/p" | sort | tr "\n" " ")
        echo "NEEDED: $needed"
        case " $needed " in *" libvulkan"*|*" libGLESv2"*|*" libEGL"*) echo "unexpected link: $needed" >&2; exit 1;; esac
        {
            echo "retroarch_commit=$(cat /src/.git/HEAD 2>/dev/null || true)"
            echo "toolchain=$IMG"
            echo "configure=${flags[*]}"
            echo "cflags=$CFLAGS"
            echo "needed=$needed"
            echo "sha256=$(sha256sum /out/retroarch | cut -d" " -f1)"
        } >/out/build-info.txt
    '
ls -l "$OUT"
cat "$OUT/build-info.txt"
