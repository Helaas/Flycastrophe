#!/usr/bin/env bash
# Flycastrophe MLP1 Pak Rat update: the installed version (e.g. 0.1.0) updated in place to the
# feed's version, the way a user's Pak Rat update goes. Drives Jawaka's own store code
# (jawaka-pakrat-smoke) against a local feed served from this Mac through adb reverse.
# Checks: ownership row moves to the new version, the installed core is CORE_SHA, the pak is still
# in the DC/NAOMI/ATOMISWAVE pickers, Flycastrophe's core options and the user's DC core choice are
# untouched. Restores the device's dev-catalog-url.
#   OUT=<dir> CORE_SHA=<sha256> FEED_ZIP=<zip> FROM_VERSION=0.1.0 TO_VERSION=0.2.0 flycastrophe-pakrat-update.sh
set -euo pipefail

LEAF=/Volumes/Storage/UMRK/Leaf
PAK_REPO="${PAK_REPO:-/Volumes/Storage/UMRK/Flycastrophe-pak}"
SMOKE_BIN=/Volumes/Storage/UMRK/.worktrees/jawaka-pakrat-smoke/build/mlp1/bin/jawaka-pakrat-smoke
OUT="${OUT:?OUT}"; CORE_SHA="${CORE_SHA:?CORE_SHA}"; FEED_ZIP="${FEED_ZIP:?FEED_ZIP}"
FROM_VERSION="${FROM_VERSION:?FROM_VERSION}"; TO_VERSION="${TO_VERSION:?TO_VERSION}"
PORT=8765
FEED_DIR="$LEAF/build/pakrat-local/flycastrophe-update"
STORE_ID="org.helaas.flycastrophe"

log() { printf 'update: %s\n' "$*" >&2; }
fail() { log "FAIL: $*"; exit 1; }
pass() { printf 'ok   %s\n' "$*"; }

mkdir -p "$OUT"
exec > >(tee "$OUT/run.log") 2>&1

SERIAL="${ADB_SERIAL:-$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}')}"
[ -n "$SERIAL" ] || fail "no online adb device"
ADB=(adb -s "$SERIAL")
SD="$(PLATFORM_ID=mlp1 REMOTE_SDCARD_PATH=auto ADB_SERIAL="$SERIAL" "$LEAF/scripts/adb-resolve-umrk-sd.sh")"
[ -n "$SD" ] || fail "could not resolve the active card"
STATE_DIR="$SD/.umrk/mlp1"
DB="$STATE_DIR/library.db"
CURRENT="$STATE_DIR/catalog/current"
DEV_CATALOG="$STATE_DIR/store/dev-catalog-url"
PAK_DIR="$SD/Apps/mlp1/Flycastrophe.pak"
OPT="$SD/.umrk/mlp1/retroarch/.config/retroarch/config/Flycastrophe/Flycastrophe.opt"
LIBS="$SD/.system/leaf/platforms/mlp1/launcher/lib"
log "device $SERIAL, card $SD"

rsh() { "${ADB[@]}" shell "$@"; }
[ "$(rsh "test -d '$LIBS' && echo yes")" = yes ] && RLIBS="$LIBS:/lib:/usr/lib" || RLIBS="/lib:/usr/lib"
UMRK_SOCKET="$(rsh 'ls -d /tmp/jawaka-runtime/jawakad.sock 2>/dev/null || true')"
[ -n "$UMRK_SOCKET" ] || UMRK_SOCKET="/tmp/jawaka-runtime/jawakad.sock"
SMOKE() { rsh "PLATFORM=mlp1 SDCARD_PATH='$SD' UMRK_INTERNAL_DATA_PATH='$STATE_DIR' \
    UMRK_PLATFORM_PATH='$SD/.system/leaf/platforms/mlp1' \
    JAWAKA_SOCKET_PATH='$UMRK_SOCKET' LD_LIBRARY_PATH='$RLIBS' /tmp/jawaka-pakrat-smoke $*"; }
sq() { rsh "sqlite3 '$DB' \"$1\"" | tr -d '\r'; }
ownership_row() { sq "select version from pakrat_installs where store_id='$STORE_ID';"; }
catalog_has_core() { local g; g="$(rsh "cat '$CURRENT' 2>/dev/null | tr -d '\r'")"; [ -n "$g" ] && rsh "grep -q '\"flycastrophe\"' '$STATE_DIR/catalog/$g/cores.json' 2>/dev/null"; }

[ -f "$FEED_ZIP" ] || fail "no $FEED_ZIP"
rm -rf "$FEED_DIR"
(cd "$LEAF" && python3 scripts/pakrat-local-feed.py --app-dir "$PAK_REPO" \
    --artifact "$STORE_ID=$FEED_ZIP" --skip-build --output "$FEED_DIR" >"$OUT/feed-gen.log")

SERVER_PID=""; SHOT=0; PRIOR_CATALOG=""
cleanup() {
    local status=$?
    set +e
    if [ "$SHOT" = 1 ]; then
        if [ -n "$PRIOR_CATALOG" ]; then rsh "printf '%s\n' '$PRIOR_CATALOG' > '$DEV_CATALOG'" >/dev/null 2>&1
        else rsh "rm -f '$DEV_CATALOG'" >/dev/null 2>&1; fi
    fi
    [ -n "$SERVER_PID" ] && { kill "$SERVER_PID" >/dev/null 2>&1; wait "$SERVER_PID" >/dev/null 2>&1; }
    "${ADB[@]}" reverse --remove "tcp:$PORT" >/dev/null 2>&1
    rsh "rm -f /tmp/jawaka-pakrat-smoke" >/dev/null 2>&1
    exit "$status"
}
trap cleanup EXIT HUP INT TERM

python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$FEED_DIR" >"$OUT/feed.log" 2>&1 &
SERVER_PID=$!
"${ADB[@]}" reverse "tcp:$PORT" "tcp:$PORT" >/dev/null
PRIOR_CATALOG="$(rsh "cat '$DEV_CATALOG' 2>/dev/null | tr -d '\r'")"
echo "prior dev-catalog-url: ${PRIOR_CATALOG:-<none>}"
rsh "mkdir -p '$STATE_DIR/store'" >/dev/null
SHOT=1
rsh "printf '%s\n' 'http://127.0.0.1:$PORT/pakrat/v1/' > '$DEV_CATALOG'"
sleep 1
rsh "wget -q -O /tmp/storefront.json 'http://127.0.0.1:$PORT/pakrat/v1/storefront.json'" || fail "device cannot reach the feed"
pass "feed reachable from device"
"${ADB[@]}" push "$SMOKE_BIN" /tmp/jawaka-pakrat-smoke >/dev/null
rsh "chmod 755 /tmp/jawaka-pakrat-smoke"

echo "=== before ==="
[ "$(ownership_row)" = "$FROM_VERSION" ] || fail "installed version is '$(ownership_row)', expected $FROM_VERSION"
opt_before="$(rsh "md5sum '$OPT' 2>/dev/null | cut -d' ' -f1")"
dc_before="$(sq "select value from system_settings where system='DC' and key='core_id';")"
games_before="$(sq "select count(*) from game_settings where value='flycastrophe';" 2>/dev/null || true)"
echo "installed $FROM_VERSION, core $(rsh "sha256sum '$PAK_DIR/cores/flycastrophe_libretro.so'" | cut -c1-16), opt md5 ${opt_before:-none}, DC choice ${dc_before:-<default>}, per-game flycastrophe rows ${games_before:-?}"
pass "baseline: $FROM_VERSION installed"

echo "=== update ==="
SMOKE install "$STORE_ID" | tee "$OUT/update.txt"
[ "$(ownership_row)" = "$TO_VERSION" ] || fail "ownership row '$(ownership_row)', expected $TO_VERSION"
got="$(rsh "sha256sum '$PAK_DIR/cores/flycastrophe_libretro.so'" | awk '{print $1}')"
[ "$got" = "$CORE_SHA" ] || fail "installed core sha $got, expected $CORE_SHA"
rsh "grep -q '\"pak_version\": \"$TO_VERSION\"' '$PAK_DIR/pak.json'" || fail "pak.json not at $TO_VERSION"
catalog_has_core || fail "catalog lost the flycastrophe core"
rsh "ls -la '$PAK_DIR' '$PAK_DIR/cores' '$PAK_DIR/info'" | tee "$OUT/installed-tree.txt"
pass "update: $FROM_VERSION -> $TO_VERSION, core $CORE_SHA, still in the catalog"

echo "=== user data ==="
[ "$(rsh "md5sum '$OPT' 2>/dev/null | cut -d' ' -f1")" = "$opt_before" ] || fail "Flycastrophe.opt changed"
[ "$(sq "select value from system_settings where system='DC' and key='core_id';")" = "$dc_before" ] || fail "DC core choice changed"
[ "$(sq "select count(*) from game_settings where value='flycastrophe';" 2>/dev/null || true)" = "$games_before" ] || fail "per-game core rows changed"
pass "core options, DC choice and per-game core rows unchanged"
echo "=== done ==="
