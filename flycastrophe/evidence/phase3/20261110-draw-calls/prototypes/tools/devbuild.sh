#!/usr/bin/env bash
# Incremental dev build of the draw-calls worktree: build-core.sh's commands, with the container's
# source copy and build tree kept in Docker volumes so only changed files recompile.
#   devbuild.sh <name>   -> $BENCH/out/fcr-<name>_libretro.so and maps/<name>.map
set -euo pipefail
NAME="${1:?name}"
SRC=/Volumes/Storage/UMRK/.worktrees/flycastrophe-draw-calls
PAK=/Volumes/Storage/UMRK/Flycastrophe-pak
BENCH=/Volumes/Storage/UMRK/tmp/dc-core-bench
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/out"; mkdir -p "$OUT" "$HERE/maps"
LOCK="$PAK/core/core.lock.json"
IMAGE="$(python3 -I -c 'import json,sys;l=json.load(open(sys.argv[1]));print(l["toolchain"]["image"]+"@"+l["toolchain"]["digest"])' "$LOCK")"
CMAKE_FLAGS="$(python3 -I -c 'import json,sys;print(" ".join(json.load(open(sys.argv[1]))["build"]["cmake_flags"]))' "$LOCK")"
docker run --rm \
  -v "$SRC":/src:ro -v "$OUT":/out -v fcr-dc-src:/tmp/src -v fcr-dc-build:/tmp/build \
  -e CMAKE_FLAGS="$CMAKE_FLAGS" "$IMAGE" bash -euc '
    git config --global --add safe.directory "*"
    . /opt/mlp1-toolchain/umrk/mlp1-build-flags.env
    TC=/opt/mlp1-toolchain/bin/$CROSS_TRIPLE
    # the tree without .git (in a worktree it points at the host); tar keeps mtimes, so ninja
    # rebuilds only what changed
    cd /src && tar --exclude=./.git -cf - . | (cd /tmp/src && tar -xf -)
    if [ ! -f /tmp/build/build.ninja ]; then
      CC=$TC-gcc CXX=$TC-g++ \
      CFLAGS="$UMRK_MLP1_PROFILE_CFLAGS" CXXFLAGS="$UMRK_MLP1_PROFILE_CXXFLAGS" \
      LDFLAGS="$UMRK_MLP1_PROFILE_LDFLAGS -Wl,-Map=/tmp/build/link.map" \
        cmake -S /tmp/src -B /tmp/build -G Ninja $CMAKE_FLAGS \
          -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
          -DCMAKE_SYSROOT="$SYSROOT" -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
          >/tmp/cmake.log 2>&1 || { tail -40 /tmp/cmake.log; exit 1; }
    fi
    ninja -C /tmp/build flycast_libretro >/tmp/ninja.log 2>&1 \
      || { grep -nE "error|fatal" -A6 /tmp/ninja.log | head -80; tail -5 /tmp/ninja.log; exit 1; }
    tail -2 /tmp/ninja.log
    cp /tmp/build/link.map /out/link.map
    cp /tmp/build/flycastrophe_libretro.so /out/
    $TC-strip --strip-unneeded /out/flycastrophe_libretro.so
  '
cp "$OUT/flycastrophe_libretro.so" "$BENCH/out/fcr-$NAME"_libretro.so
cp "$OUT/link.map" "$HERE/maps/$NAME.map"
shasum -a 256 "$BENCH/out/fcr-$NAME"_libretro.so
