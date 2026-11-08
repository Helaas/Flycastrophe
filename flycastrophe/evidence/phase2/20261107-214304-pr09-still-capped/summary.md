Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr03 | 1/1 | 60.00 | 60.00 | 60.00 | 60.0 | 17.9 | 1.3 | 0 | 54 | 1.43 | 223 | 67.5 |
| fcr-pr09 | 1/1 | 60.00 | 60.00 | 60.00 | 60.0 | 17.5 | 0.4 | 0 | 53 | 1.37 | 229 | 65.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr03 | 200 | retroarch 94, Flycast-emu 81, deadcast-aica 13, mali-cmar-backe 10, threaded-ml 1 | 18 | 59 |
| fcr-pr09 | 199 | retroarch 83, Flycast-emu 79, deadcast-aica 14, deadcast-parse 12, mali-cmar-backe 9 | 16 | 58 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr03 | 1/1 | 60.08 | 59.94 | 59.92 | 60.1 | 17.3 | 0.4 | 0 | 42 | 1.38 | 228 | 65.6 |
| fcr-pr09 | 1/1 | 60.08 | 59.92 | 59.92 | 60.1 | 17.5 | 0.4 | 0 | 41 | 1.35 | 226 | 66.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr03 | 165 | Flycast-emu 79, retroarch 63, deadcast-aica 12, mali-cmar-backe 9, threaded-ml 1 | 17 | 50 |
| fcr-pr09 | 169 | Flycast-emu 77, retroarch 59, deadcast-aica 11, deadcast-parse 10, mali-cmar-backe 9 | 16 | 50 |

### Each arm against fcr-pr03 (no worse = pass)

- crazy-taxi fcr-pr09: median fps pass (60.00 vs 60.00); frame p95 pass (17.5 vs 17.9 ms); underruns pass (0.4 vs 1.3 %); startup pass (1.37 vs 1.43 s)
- sa2 fcr-pr09: median fps pass (60.08 vs 60.08); frame p95 FAIL (17.5 vs 17.3 ms); underruns pass (0.4 vs 0.4 %); startup pass (1.35 vs 1.38 s)
