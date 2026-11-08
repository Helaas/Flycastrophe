#!/usr/bin/env python3
"""Summarise a tools/phase0/bench.sh suite: GLES vs Vulkan, per game.

usage: summarize.py SUITE_DIR

FPS comes from frame-counter deltas between the 5 s GET_PERF_INFO samples
(the reply's own fps field is a rolling 2048-frame average). Round 0 is the
discarded warm-up rep and is left out of every number.
"""
import os
import re
import statistics
import sys
from collections import defaultdict

HZ = 100


def kv(line):
    return dict(re.findall(r"(\w+)=([^\s]+)", line))


def pct(values, q):
    s = sorted(values)
    if not s:
        return float("nan")
    k = (len(s) - 1) * q
    lo, hi = int(k), min(int(k) + 1, len(s) - 1)
    return s[lo] + (s[hi] - s[lo]) * (k - lo)


def read_meta(run):
    meta = {}
    with open(os.path.join(run, "meta.txt")) as f:
        for line in f:
            if "=" in line:
                k, v = line.rstrip("\n").split("=", 1)
                meta[k] = v
    return meta


def read_cpu(path):
    snap = {"threads": {}}
    if not os.path.exists(path):
        return None
    with open(path) as f:
        for line in f:
            p = line.split()
            if not p:
                continue
            if p[0] == "uptime":
                snap["uptime"] = float(p[1])
            elif p[0] == "cpu":
                vals = [int(x) for x in p[1:]]
                snap["busy"] = sum(vals) - vals[3] - vals[4]
                snap["total"] = sum(vals)
            elif p[0] == "weston":
                snap["weston"] = int(p[1]) + int(p[2])
            elif p[0] == "thread":
                snap["threads"][p[1]] = (p[2], int(p[3]) + int(p[4]))
    return snap


def cpu_window(run):
    a = read_cpu(os.path.join(run, "cpu-start.txt"))
    b = read_cpu(os.path.join(run, "cpu-end.txt"))
    if not a or not b or "uptime" not in a or "uptime" not in b:
        return None
    dt = b["uptime"] - a["uptime"]
    if dt <= 0:
        return None
    per_name = defaultdict(float)
    ra_total = 0.0
    for tid, (name, j1) in b["threads"].items():
        j0 = a["threads"].get(tid, (name, 0))[1]
        share = (j1 - j0) / HZ / dt * 100.0  # percent of one core
        per_name[name] += share
        ra_total += share
    soc = (b["busy"] - a["busy"]) / max(1, b["total"] - a["total"]) * 100.0  # of all 4 cores
    weston = (b.get("weston", 0) - a.get("weston", 0)) / HZ / dt * 100.0
    return {"ra": ra_total, "threads": dict(per_name), "weston": weston, "soc": soc}


def load(run):
    meta = read_meta(run)
    rows = []
    path = os.path.join(run, "samples.txt")
    if os.path.exists(path):
        with open(path) as f:
            rows = [kv(line) for line in f if "frames=" in line]
    fps = []
    for a, b in zip(rows, rows[1:]):
        dt = float(b["uptime"]) - float(a["uptime"])
        df = int(b["frames"]) - int(a["frames"])
        if dt > 0:
            fps.append(df / dt)
    num = lambda key: [float(r[key]) for r in rows if key in r]
    return {
        "meta": meta,
        "ok": meta.get("result") == "ok" and bool(fps),
        "fps": fps,
        "p95": num("frame_time_p95_ms")[-1] if num("frame_time_p95_ms") else float("nan"),
        "underrun": statistics.mean(num("audio_underrun_pct")) if num("audio_underrun_pct") else float("nan"),
        "dropped": (int(rows[-1]["dropped"]) - int(rows[0]["dropped"])) if len(rows) > 1 else 0,
        "gpuload": statistics.mean(num("gpuload")) if num("gpuload") else float("nan"),
        "temp": max(num("temp")) / 1000.0 if num("temp") else float("nan"),
        "rss": max(num("rss_kb")) / 1024.0 if num("rss_kb") else float("nan"),
        "startup": float(meta["startup_s"]) if "startup_s" in meta else float("nan"),
        "cpu": cpu_window(run),
    }


def main():
    suite = sys.argv[1]
    groups = defaultdict(list)
    for name in sorted(os.listdir(suite)):
        run = os.path.join(suite, name)
        if not os.path.isfile(os.path.join(run, "meta.txt")):
            continue
        d = load(run)
        if d["meta"].get("round") == "0":
            continue
        groups[(d["meta"]["game"], d["meta"]["arm"])].append(d)

    stats = {}
    first = next((d for ds in groups.values() for d in ds), None)
    uncapped = bool(first) and first["meta"].get("uncapped") == "1"
    if first:
        print(f"Mode: uncapped={first['meta'].get('uncapped', '0')} drive={first['meta'].get('drive', '1')} "
              f"warmup={first['meta'].get('warmup_s')}s window={first['meta'].get('seconds')}s")
    for game in sorted({g for g, _ in groups}):
        print(f"\n### {game}\n")
        print("| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |")
        print("| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
        for arm in ("gles", "vk"):
            ds = groups.get((game, arm), [])
            ok = [d for d in ds if d["ok"]]
            if not ok:
                print(f"| {arm} | 0/{len(ds)} | | | | | | | | | | | |")
                continue
            pooled = [x for d in ok for x in d["fps"]]
            s = {
                "median": statistics.median(pooled), "p5": pct(pooled, 0.05), "min": min(pooled),
                "p95": statistics.median(d["p95"] for d in ok),
                "underrun": statistics.mean(d["underrun"] for d in ok),
                "dropped": sum(d["dropped"] for d in ok),
                "gpuload": statistics.mean(d["gpuload"] for d in ok),
                "startup": statistics.median(d["startup"] for d in ok),
                "rss": max(d["rss"] for d in ok), "temp": max(d["temp"] for d in ok),
            }
            stats[(game, arm)] = s
            reps = ", ".join(f"{statistics.median(d['fps']):.1f}" for d in ok)
            print(f"| {arm} | {len(ok)}/{len(ds)} | {s['median']:.2f} | {s['p5']:.2f} | {s['min']:.2f} | {reps} | "
                  f"{s['p95']:.1f} | {s['underrun']:.1f} | {s['dropped']} | {s['gpuload']:.0f} | {s['startup']:.2f} | "
                  f"{s['rss']:.0f} | {s['temp']:.1f} |")

        print("\nCPU over the window, percent of one core (mean of reps):\n")
        print("| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |")
        print("| --- | ---: | --- | ---: | ---: |")
        for arm in ("gles", "vk"):
            cpus = [d["cpu"] for d in groups.get((game, arm), []) if d["ok"] and d["cpu"]]
            if not cpus:
                continue
            names = defaultdict(list)
            for c in cpus:
                for n, v in c["threads"].items():
                    names[n].append(v)
            top = sorted(((statistics.mean(v), n) for n, v in names.items()), reverse=True)[:5]
            tops = ", ".join(f"{n} {v:.0f}" for v, n in top if v >= 1)
            print(f"| {arm} | {statistics.mean(c['ra'] for c in cpus):.0f} | {tops} | "
                  f"{statistics.mean(c['weston'] for c in cpus):.0f} | {statistics.mean(c['soc'] for c in cpus):.0f} |")

    if uncapped:
        print("\n### Uncapped: Vulkan relative to GLES\n")
        for game in sorted({g for g, _ in groups}):
            g, v = stats.get((game, "gles")), stats.get((game, "vk"))
            if not g or not v:
                print(f"- {game}: incomplete")
                continue
            rel = lambda a, b: (a / b - 1.0) * 100.0
            print(f"- {game}: median fps {v['median']:.2f} vs {g['median']:.2f} ({rel(v['median'], g['median']):+.1f}%), "
                  f"p5 {v['p5']:.2f} vs {g['p5']:.2f} ({rel(v['p5'], g['p5']):+.1f}%), "
                  f"frame p95 {v['p95']:.1f} vs {g['p95']:.1f} ms")
        return

    print("\n### Gate (Phase 0 step 6, numbers part)\n")
    for game in sorted({g for g, _ in groups}):
        g, v = stats.get((game, "gles")), stats.get((game, "vk"))
        if not g or not v:
            print(f"- {game}: incomplete")
            continue
        checks = [
            ("median fps", v["median"] >= g["median"], f"{v['median']:.2f} vs {g['median']:.2f}"),
            ("frame p95", v["p95"] <= g["p95"], f"{v['p95']:.1f} vs {g['p95']:.1f} ms"),
            ("underruns", v["underrun"] <= g["underrun"], f"{v['underrun']:.1f} vs {g['underrun']:.1f} %"),
            ("startup", v["startup"] <= g["startup"] + 1.0, f"{v['startup']:.2f} vs {g['startup']:.2f} s"),
        ]
        line = "; ".join(f"{n} {'pass' if ok else 'FAIL'} ({txt})" for n, ok, txt in checks)
        print(f"- {game}: {line}")


if __name__ == "__main__":
    main()
