Mode: uncapped=1 drive=0 warmup=10s window=45s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-main | 2/2 | 57.39 | 52.62 | 51.06 | 56.1, 65.1 | 18.7 | 14.3 | 11 | 65 | 1.42 | 296 | 68.1 |
| fcr-pr02 | 2/2 | 55.46 | 51.08 | 46.36 | 65.3, 53.9 | 19.7 | 14.5 | 9 | 64 | 1.44 | 295 | 69.4 |

Replay played to its end (start to exit, lower is faster): fcr-main median 97.73 s (104.23, 91.23); fcr-pr02 median 99.09 s (91.31, 106.87)

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-main | 186 | Flycast-emu 98, retroarch 76, mali-cmar-backe 11, threaded-ml 2 | 17 | 56 |
| fcr-pr02 | 185 | Flycast-emu 97, retroarch 75, mali-cmar-backe 11, threaded-ml 2 | 17 | 55 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-main | 2/2 | 59.83 | 51.96 | 51.63 | 59.8, 59.8 | 19.6 | 4.4 | 9 | 50 | 1.42 | 318 | 67.5 |
| fcr-pr02 | 2/2 | 57.85 | 51.92 | 51.92 | 56.8, 58.6 | 19.8 | 5.1 | 18 | 50 | 1.43 | 321 | 67.5 |

Replay played to its end (start to exit, lower is faster): fcr-main median 98.67 s (96.66, 100.69); fcr-pr02 median 104.49 s (105.43, 103.54)

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-main | 182 | Flycast-emu 99, retroarch 71, mali-cmar-backe 10, threaded-ml 2 | 18 | 55 |
| fcr-pr02 | 180 | Flycast-emu 99, retroarch 68, mali-cmar-backe 10, threaded-ml 2 | 18 | 54 |

### Uncapped: each arm relative to fcr-main

- crazy-taxi fcr-pr02: median fps 55.46 vs 57.39 (-3.4%), p5 51.08 vs 52.62 (-2.9%), frame p95 19.7 vs 18.7 ms
- sa2 fcr-pr02: median fps 57.85 vs 59.83 (-3.3%), p5 51.92 vs 51.96 (-0.1%), frame p95 19.8 vs 19.6 ms
