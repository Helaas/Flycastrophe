Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 2/2 | 58.46 | 57.08 | 57.03 | 58.4, 58.5 | 18.8 | 12.6 | 0 | 53 | 1.36 | 233 | 65.0 |
| fastumrk | 2/2 | 35.01 | 34.31 | 34.17 | 34.8, 35.2 | 42.5 | 0.1 | 969 | 27 | 1.43 | 234 | 59.4 |
| fcr-rel | 2/2 | 60.00 | 59.95 | 59.88 | 60.1, 60.0 | 17.2 | 0.5 | 0 | 53 | 1.71 | 249 | 63.3 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 204 | Flycast-emu 99, retroarch 94, mali-cmar-backe 10, threaded-ml 1 | 19 | 60 |
| fastumrk | 116 | retroarch 109, mali-cmar-backe 5, threaded-ml 3 | 11 | 36 |
| fcr-rel | 177 | retroarch 80, Flycast-emu 64, deadcast-aica 13, mali-cmar-backe 10, deadcast-parse 9 | 15 | 53 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 2/2 | 59.92 | 59.59 | 59.42 | 59.8, 60.0 | 17.5 | 3.6 | 2 | 42 | 1.36 | 236 | 63.3 |
| fastumrk | 2/2 | 58.15 | 56.85 | 56.76 | 57.7, 58.6 | 33.4 | 0.2 | 403 | 40 | 1.44 | 229 | 60.6 |
| fcr-rel | 2/2 | 60.04 | 59.99 | 59.92 | 60.0, 60.1 | 17.4 | 0.3 | 0 | 41 | 1.81 | 239 | 62.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 178 | Flycast-emu 97, retroarch 68, mali-cmar-backe 10, threaded-ml 2 | 18 | 54 |
| fastumrk | 116 | retroarch 106, mali-cmar-backe 7, threaded-ml 2 | 16 | 38 |
| fcr-rel | 148 | Flycast-emu 61, retroarch 57, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 15 | 45 |

### Each arm against gles (no worse = pass)

- crazy-taxi fastumrk: median fps FAIL (35.01 vs 58.46); frame p95 FAIL (42.5 vs 18.8 ms); underruns pass (0.1 vs 12.6 %); startup pass (1.43 vs 1.36 s)
- crazy-taxi fcr-rel: median fps pass (60.00 vs 58.46); frame p95 pass (17.2 vs 18.8 ms); underruns pass (0.5 vs 12.6 %); startup pass (1.71 vs 1.36 s)
- sa2 fastumrk: median fps FAIL (58.15 vs 59.92); frame p95 FAIL (33.4 vs 17.5 ms); underruns pass (0.2 vs 3.6 %); startup pass (1.44 vs 1.36 s)
- sa2 fcr-rel: median fps pass (60.04 vs 59.92); frame p95 pass (17.4 vs 17.5 ms); underruns pass (0.3 vs 3.6 %); startup pass (1.81 vs 1.36 s)
