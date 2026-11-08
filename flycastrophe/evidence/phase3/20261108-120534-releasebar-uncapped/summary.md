Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 3/3 | 58.94 | 56.85 | 56.45 | 59.0, 59.2, 57.9 | 18.2 | 11.5 | 0 | 53 | 1.13 | 232 | 60.6 |
| fastumrk | 3/3 | 48.46 | 48.04 | 47.88 | 48.5, 48.3, 48.5 | 22.0 | 0.1 | 4 | 39 | 1.08 | 236 | 59.4 |
| fcr-rel | 3/3 | 71.57 | 69.39 | 68.14 | 71.4, 71.8, 71.3 | 14.9 | 0.3 | 0 | 63 | 1.40 | 250 | 62.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 204 | Flycast-emu 99, retroarch 94, mali-cmar-backe 10, threaded-ml 2 | 18 | 60 |
| fastumrk | 181 | retroarch 171, mali-cmar-backe 8, threaded-ml 3 | 16 | 54 |
| fcr-rel | 216 | retroarch 98, Flycast-emu 77, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 17 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 3/3 | 61.38 | 59.82 | 59.23 | 61.6, 60.7, 61.3 | 17.3 | 3.6 | 0 | 43 | 1.16 | 234 | 60.6 |
| fastumrk | 3/3 | 103.27 | 101.40 | 100.58 | 103.8, 102.8, 102.9 | 10.8 | 0.1 | 0 | 68 | 1.11 | 234 | 63.3 |
| fcr-rel | 3/3 | 91.38 | 90.53 | 90.19 | 91.6, 91.4, 91.4 | 12.3 | 0.1 | 0 | 62 | 1.52 | 239 | 65.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 183 | Flycast-emu 99, retroarch 72, mali-cmar-backe 11, threaded-ml 2 | 18 | 55 |
| fastumrk | 207 | retroarch 191, mali-cmar-backe 13, threaded-ml 2 | 19 | 62 |
| fcr-rel | 231 | Flycast-emu 98, retroarch 88, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |

### Uncapped: each arm relative to gles

- crazy-taxi fastumrk: median fps 48.46 vs 58.94 (-17.8%), p5 48.04 vs 56.85 (-15.5%), frame p95 22.0 vs 18.2 ms
- crazy-taxi fcr-rel: median fps 71.57 vs 58.94 (+21.4%), p5 69.39 vs 56.85 (+22.1%), frame p95 14.9 vs 18.2 ms
- sa2 fastumrk: median fps 103.27 vs 61.38 (+68.2%), p5 101.40 vs 59.82 (+69.5%), frame p95 10.8 vs 17.3 ms
- sa2 fcr-rel: median fps 91.38 vs 61.38 (+48.9%), p5 90.53 vs 59.82 (+51.3%), frame p95 12.3 vs 17.3 ms
