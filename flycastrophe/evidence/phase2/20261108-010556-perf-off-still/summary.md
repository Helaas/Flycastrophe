Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-gdlock | 1/1 | 71.09 | 70.48 | 70.44 | 71.1 | 15.0 | 0.3 | 0 | 64 | 1.40 | 237 | 68.8 |
| fcr-perf | 1/1 | 70.19 | 68.99 | 68.98 | 70.2 | 15.2 | 0.3 | 0 | 63 | 1.38 | 237 | 66.9 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-gdlock | 216 | retroarch 99, Flycast-emu 76, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 64 |
| fcr-perf | 216 | retroarch 99, Flycast-emu 77, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-gdlock | 1/1 | 90.98 | 90.97 | 90.96 | 91.0 | 12.1 | 0.1 | 0 | 62 | 1.48 | 225 | 71.1 |
| fcr-perf | 1/1 | 90.20 | 88.93 | 88.85 | 90.2 | 12.4 | 0.0 | 0 | 61 | 1.50 | 230 | 70.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-gdlock | 231 | Flycast-emu 99, retroarch 88, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |
| fcr-perf | 229 | Flycast-emu 98, retroarch 87, deadcast-aica 16, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |

### Uncapped: each arm relative to fcr-gdlock

- crazy-taxi fcr-perf: median fps 70.19 vs 71.09 (-1.3%), p5 68.99 vs 70.48 (-2.1%), frame p95 15.2 vs 15.0 ms
- sa2 fcr-perf: median fps 90.20 vs 90.98 (-0.9%), p5 88.93 vs 90.97 (-2.2%), frame p95 12.4 vs 12.1 ms
