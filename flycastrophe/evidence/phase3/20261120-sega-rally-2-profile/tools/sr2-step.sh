#!/usr/bin/env bash
# sr2-step.sh OUT NAME [press args...] : optional press, then a screenshot OUT/NAME.png and the last perf line
BENCH_HOST=/Volumes/Storage/UMRK/tmp/dc-core-bench
. "$BENCH_HOST/lib-bench.sh"
OUT="$1"; NAME="$2"; shift 2
[ $# -gt 0 ] && { press "$@"; sleep "${WAIT:-2}"; }
screenshot "$OUT/$NAME.png" >/dev/null 2>&1
sh_ "grep 'Flycastrophe perf' '$DEV_DIR/retroarch.log' | tail -1" | sed -E 's/.*perf +([0-9.]+) s: vblank +[0-9.]+\/s +([0-9.]+)% .*emu cpu +([0-9]+)%.*mmu flushes ([0-9+]+) misses ([0-9]+).*draws ([0-9]+).*/t=\1 speed=\2% emu=\3% flushes=\4 misses=\5 draws=\6/'
