Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 3/3 | 58.98 | 57.63 | 57.31 | 59.0, 59.4, 58.7 | 18.3 | 9.2 | 1 | 53 | 1.14 | 236 | 66.2 |
| fcr-base | 3/3 | 59.81 | 59.27 | 59.04 | 60.5, 60.0, 59.5 | 17.8 | 3.1 | 0 | 55 | 1.10 | 237 | 66.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 205 | Flycast-emu 99, retroarch 95, mali-cmar-backe 10, threaded-ml 2 | 18 | 61 |
| fcr-base | 203 | Flycast-emu 99, retroarch 93, mali-cmar-backe 10, threaded-ml 2 | 18 | 60 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 3/3 | 60.77 | 60.21 | 59.88 | 60.8, 60.8, 60.7 | 17.4 | 2.3 | 0 | 43 | 1.13 | 232 | 65.0 |
| fcr-base | 3/3 | 63.15 | 60.95 | 60.89 | 64.2, 63.1, 61.8 | 16.9 | 1.6 | 0 | 44 | 1.12 | 238 | 64.4 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 184 | Flycast-emu 99, retroarch 72, mali-cmar-backe 11, threaded-ml 2 | 18 | 55 |
| fcr-base | 182 | Flycast-emu 99, retroarch 70, mali-cmar-backe 11, threaded-ml 2 | 18 | 55 |

### Uncapped: each arm relative to gles

- crazy-taxi fcr-base: median fps 59.81 vs 58.98 (+1.4%), p5 59.27 vs 57.63 (+2.8%), frame p95 17.8 vs 18.3 ms
- sa2 fcr-base: median fps 63.15 vs 60.77 (+3.9%), p5 60.95 vs 60.21 (+1.2%), frame p95 16.9 vs 17.4 ms
