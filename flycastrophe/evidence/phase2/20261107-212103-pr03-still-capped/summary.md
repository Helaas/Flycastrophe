Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-main | 1/1 | 59.98 | 59.90 | 59.88 | 60.0 | 17.9 | 2.9 | 0 | 54 | 1.42 | 227 | 69.4 |
| fcr-pr03 | 1/1 | 60.08 | 59.88 | 59.85 | 60.1 | 17.8 | 1.5 | 0 | 54 | 1.43 | 222 | 68.1 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-main | 203 | Flycast-emu 99, retroarch 93, mali-cmar-backe 10, threaded-ml 1 | 19 | 60 |
| fcr-pr03 | 200 | retroarch 93, Flycast-emu 82, deadcast-aica 14, mali-cmar-backe 10, threaded-ml 1 | 18 | 59 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-main | 1/1 | 60.00 | 59.97 | 59.96 | 60.0 | 17.3 | 0.8 | 0 | 42 | 1.44 | 224 | 67.5 |
| fcr-pr03 | 1/1 | 60.08 | 59.93 | 59.88 | 60.1 | 17.4 | 0.5 | 0 | 42 | 1.39 | 224 | 66.9 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-main | 169 | Flycast-emu 93, retroarch 64, mali-cmar-backe 10, threaded-ml 2 | 18 | 52 |
| fcr-pr03 | 165 | Flycast-emu 80, retroarch 63, deadcast-aica 12, mali-cmar-backe 9, threaded-ml 1 | 17 | 50 |

### Each arm against fcr-main (no worse = pass)

- crazy-taxi fcr-pr03: median fps pass (60.08 vs 59.98); frame p95 pass (17.8 vs 17.9 ms); underruns pass (1.5 vs 2.9 %); startup pass (1.43 vs 1.42 s)
- sa2 fcr-pr03: median fps pass (60.08 vs 60.00); frame p95 FAIL (17.4 vs 17.3 ms); underruns pass (0.5 vs 0.8 %); startup pass (1.39 vs 1.44 s)
