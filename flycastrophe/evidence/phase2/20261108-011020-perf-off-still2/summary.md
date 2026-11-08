Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-perf | 1/1 | 71.57 | 70.58 | 70.31 | 71.6 | 15.0 | 0.3 | 0 | 64 | 1.35 | 237 | 71.1 |
| fcr-gdlock | 1/1 | 71.06 | 69.45 | 69.10 | 71.1 | 14.9 | 0.3 | 0 | 63 | 1.41 | 237 | 70.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-perf | 218 | retroarch 98, Flycast-emu 79, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 12 | 18 | 64 |
| fcr-gdlock | 214 | retroarch 98, Flycast-emu 76, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 17 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-perf | 1/1 | 90.13 | 89.64 | 89.50 | 90.1 | 12.3 | 0.0 | 0 | 61 | 1.46 | 225 | 72.2 |
| fcr-gdlock | 1/1 | 90.79 | 90.77 | 90.77 | 90.8 | 12.1 | 0.1 | 0 | 61 | 1.53 | 225 | 72.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-perf | 229 | Flycast-emu 99, retroarch 86, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |
| fcr-gdlock | 231 | Flycast-emu 99, retroarch 88, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |

### Uncapped: each arm relative to fcr-perf

- crazy-taxi fcr-gdlock: median fps 71.06 vs 71.57 (-0.7%), p5 69.45 vs 70.58 (-1.6%), frame p95 14.9 vs 15.0 ms
- sa2 fcr-gdlock: median fps 90.79 vs 90.13 (+0.7%), p5 90.77 vs 89.64 (+1.3%), frame p95 12.1 vs 12.3 ms
