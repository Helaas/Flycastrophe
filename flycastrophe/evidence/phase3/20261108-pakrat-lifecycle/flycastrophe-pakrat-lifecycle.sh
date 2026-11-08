#!/usr/bin/env bash
# Flycastrophe MLP1 Pak Rat lifecycle, adapted from Leaf/scripts/adb-dsperate-lifecycle.sh.
# Drives Jawaka's own store code (jawaka-pakrat-smoke, built from Jawaka main) against a local feed
# served from this Mac through adb reverse:
#   install -> reinstall -> catalog/picker -> run the installed core -> uninstall -> recovery -> reinstall
# Restores the device's dev-catalog-url and the DC core choice it found. Ends with Flycastrophe installed.
set -euo pipefail

LEAF=/Volumes/Storage/UMRK/Leaf
PAK_REPO=/Volumes/Storage/UMRK/Flycastrophe-pak
SMOKE_BIN=/Volumes/Storage/UMRK/.worktrees/jawaka-pakrat-smoke/build/mlp1/bin/jawaka-pakrat-smoke
OUT="${OUT:?OUT}"
PORT=8765
FEED_DIR="$LEAF/build/pakrat-local/flycastrophe-lifecycle"
STORE_ID="org.helaas.flycastrophe"
STORE_VERSION="0.1.0"
FEED_ZIP="$PAK_REPO/build/dist/Flycastrophe.mlp1.pak.zip"
CORE_SHA=4a22ad60b6c94dcb1a0421c0bad3db236b87f073d216ef0c32bd8ad99ba9c2b6

log() { printf 'lifecycle: %s\n' "$*" >&2; }
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

# --- feed ----------------------------------------------------------------------
[ -f "$FEED_ZIP" ] || fail "no $FEED_ZIP (make dist-pakrat)"
rm -rf "$FEED_DIR"
(cd "$LEAF" && python3 scripts/pakrat-local-feed.py --app-dir "$PAK_REPO" \
    --artifact "$STORE_ID=$FEED_ZIP" --skip-build --output "$FEED_DIR" >"$OUT/feed-gen.log")

SERVER_PID=""; SHOT=0; PRIOR_CATALOG=""; PRIOR_DC=""
cleanup() {
    local status=$?
    set +e
    if [ "$SHOT" = 1 ]; then
        if [ -n "$PRIOR_CATALOG" ]; then rsh "printf '%s\n' '$PRIOR_CATALOG' > '$DEV_CATALOG'" >/dev/null 2>&1
        else rsh "rm -f '$DEV_CATALOG'" >/dev/null 2>&1; fi
    fi
    # the DC core choice as it was found (no row = Leaf's default)
    if [ -n "$PRIOR_DC" ]; then
        sq "update system_settings set value='$PRIOR_DC' where system='DC' and key='core_id';" >/dev/null 2>&1
    else
        sq "delete from system_settings where system='DC' and key='core_id';" >/dev/null 2>&1
    fi
    [ -n "$SERVER_PID" ] && { kill "$SERVER_PID" >/dev/null 2>&1; wait "$SERVER_PID" >/dev/null 2>&1; }
    "${ADB[@]}" reverse --remove "tcp:$PORT" >/dev/null 2>&1
    rsh "rm -f /tmp/jawaka-pakrat-smoke /userdata/dc-core-bench/cores/fcr-pakrat_libretro.so" >/dev/null 2>&1
    exit "$status"
}
trap cleanup EXIT HUP INT TERM

python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$FEED_DIR" >"$OUT/feed.log" 2>&1 &
SERVER_PID=$!
"${ADB[@]}" reverse "tcp:$PORT" "tcp:$PORT" >/dev/null
PRIOR_CATALOG="$(rsh "cat '$DEV_CATALOG' 2>/dev/null | tr -d '\r'")"
PRIOR_DC="$(sq "select value from system_settings where system='DC' and key='core_id';")"
echo "prior dev-catalog-url: ${PRIOR_CATALOG:-<none>}; prior DC core choice: ${PRIOR_DC:-<default>}"
rsh "mkdir -p '$STATE_DIR/store'" >/dev/null
SHOT=1
rsh "printf '%s\n' 'http://127.0.0.1:$PORT/pakrat/v1/' > '$DEV_CATALOG'"
sleep 1
rsh "wget -q -O /tmp/storefront.json 'http://127.0.0.1:$PORT/pakrat/v1/storefront.json'" || fail "device cannot reach the feed"
pass "feed reachable from device"

"${ADB[@]}" push "$SMOKE_BIN" /tmp/jawaka-pakrat-smoke >/dev/null
rsh "chmod 755 /tmp/jawaka-pakrat-smoke"
pass "pushed jawaka-pakrat-smoke"

catalog_gen() { rsh "cat '$CURRENT' 2>/dev/null | tr -d '\r'" || true; }
catalog_has_core() { local g; g="$(catalog_gen)"; [ -n "$g" ] && rsh "grep -q '\"flycastrophe\"' '$STATE_DIR/catalog/$g/cores.json' 2>/dev/null"; }
alternates_of() {  # alternates_of <system id>: the system's alternate_cores in the effective catalog
    local g; g="$(catalog_gen)"
    "${ADB[@]}" exec-out cat "$STATE_DIR/catalog/$g/systems.json" | python3 -I -c '
import json,sys
d=json.load(sys.stdin); d=d if isinstance(d,list) else d.get("systems",[])
s=[x for x in d if x.get("id")==sys.argv[1]]
print(s[0].get("default_core",""), ",".join(s[0].get("alternate_cores",[])) if s else "")' "$1"
}
ownership_row() { sq "select version from pakrat_installs where store_id='$STORE_ID';"; }

echo "=== baseline ==="
if [ -n "$(ownership_row)" ]; then
    log "Flycastrophe is installed from an earlier run: uninstalling it first"
    SMOKE uninstall "$STORE_ID" > "$OUT/pre-uninstall.txt"
fi
echo "catalog=$(catalog_gen)"
echo "pak dir: $(rsh "test -d '$PAK_DIR' && echo present || echo absent")"
for s in DC NAOMI ATOMISWAVE; do echo "$s default+alternates: $(alternates_of $s)"; done
catalog_has_core && fail "flycastrophe already in the catalog before install"
pass "baseline: no Flycastrophe"

echo "=== install ==="
SMOKE install "$STORE_ID" | tee "$OUT/install.txt"
[ "$(ownership_row)" = "$STORE_VERSION" ] || fail "ownership row not at $STORE_VERSION"
rsh "test ! -e '$PAK_DIR/launch.sh'" || fail "content pak must not have launch.sh"
got="$(rsh "sha256sum '$PAK_DIR/cores/flycastrophe_libretro.so'" | awk '{print $1}')"
[ "$got" = "$CORE_SHA" ] || fail "installed core sha $got, expected $CORE_SHA"
rsh "ls -la '$PAK_DIR' '$PAK_DIR/cores' '$PAK_DIR/info'" | tee "$OUT/installed-tree.txt"
catalog_has_core || fail "catalog did not gain the flycastrophe core"
for s in DC NAOMI ATOMISWAVE; do
    a="$(alternates_of $s)"; echo "$s: $a"
    case ",${a#* }," in *,flycastrophe,*) ;; *) fail "$s alternates lack flycastrophe" ;; esac
done
pass "install: core $CORE_SHA, in the catalog and in the DC, NAOMI and Atomiswave pickers, no Apps entry"

echo "=== reinstall ==="
SMOKE install "$STORE_ID" | tee "$OUT/reinstall.txt"
[ "$(ownership_row)" = "$STORE_VERSION" ] || fail "reinstall changed the ownership row"
catalog_has_core || fail "reinstall lost the core"
pass "reinstall idempotent"

echo "=== picker persistence ==="
sq "insert into system_settings(system,key,value,updated_at) values('DC','core_id','flycastrophe',strftime('%s','now')) on conflict(system,key) do update set value='flycastrophe',updated_at=strftime('%s','now');"
SMOKE rescan >/dev/null 2>&1 || true
[ "$(sq "select value from system_settings where system='DC' and key='core_id';")" = flycastrophe ] || fail "saved DC choice not retained"
catalog_has_core || fail "core vanished after rescan"
pass "DC choice of flycastrophe retained across rescan"

echo "=== run the installed core (bench RetroArch config, no RetroAchievements login) ==="
set +e
. /Volumes/Storage/UMRK/tmp/dc-core-bench/lib-bench.sh >/dev/null 2>&1
rsh "ln -sf '$PAK_DIR/cores/flycastrophe_libretro.so' /userdata/dc-core-bench/cores/fcr-pakrat_libretro.so"
write_ra_cfg 1
rsh "echo 'input_player2_joypad_index = \"7\"' >> /userdata/dc-core-bench/retroarch.cfg" >/dev/null
rsh "rm -f /userdata/dc-core-bench/states/*" >/dev/null
rom="$(resolve_rom crazy-taxi)"; base="$(state_basename "$rom")"
"${ADB[@]}" push /Volumes/Storage/UMRK/tmp/dc-core-bench/states/upstream-crazy-taxi.state "/userdata/dc-core-bench/states/$base.state.auto" >/dev/null
pause_launcher
start_ra fcr-pakrat "$rom" || { resume_launcher; fail "installed core did not start"; }
sleep 20
screenshot "$OUT/installed-core-crazy-taxi.png" >/dev/null 2>&1 || true
ra_cmd "raw-send QUIT" >/dev/null; ra_cmd "raw-send QUIT" >/dev/null
rsh "for i in \$(seq 1 50); do pidof retroarch >/dev/null || break; sleep 0.1; done; pidof retroarch >/dev/null && echo STILL-RUNNING; true"
"${ADB[@]}" exec-out cat /userdata/dc-core-bench/retroarch.log > "$OUT/installed-core-retroarch.log"
resume_launcher
grep -q "Deadcast: the dynarec's window" "$OUT/installed-core-retroarch.log" || fail "log does not show Flycastrophe's dynarec"
grep -q 'terminate called' "$OUT/installed-core-retroarch.log" && fail "RetroArch aborted at exit"
grep -q 'Unloading core symbols' "$OUT/installed-core-retroarch.log" || fail "no clean unload after QUIT"
pass "installed core ran Crazy Taxi from its state and quit cleanly"
set -e

echo "=== uninstall ==="
SMOKE uninstall "$STORE_ID" | tee "$OUT/uninstall.txt"
rsh "test ! -d '$PAK_DIR'" || fail "pak directory survived uninstall"
[ -z "$(ownership_row)" ] || fail "ownership row survived uninstall"
catalog_has_core && fail "catalog still advertises flycastrophe after uninstall"
for s in DC NAOMI ATOMISWAVE; do
    a="$(alternates_of $s)"; echo "$s: $a"
    case ",${a#* }," in *,flycastrophe,*) fail "$s still lists flycastrophe" ;; esac
done
[ "$(sq "select value from system_settings where system='DC' and key='core_id';")" = flycastrophe ] \
    || fail "the saved choice was cleared instead of falling back"
pass "uninstall: pak, ownership and pickers retracted; saved DC choice kept, DC default is $(alternates_of DC | cut -d' ' -f1)"

echo "=== final: installed ==="
SMOKE install "$STORE_ID" | tee "$OUT/final-install.txt"
catalog_has_core || fail "final reinstall did not restore the core"
[ "$(ownership_row)" = "$STORE_VERSION" ] || fail "final ownership row"
pass "final state: Flycastrophe $STORE_VERSION installed from the feed"
echo "=== done ==="
