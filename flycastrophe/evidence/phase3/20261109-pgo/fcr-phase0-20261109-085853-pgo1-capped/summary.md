Mode: uncapped=0 drive=1 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel11 | 2/2 | 60.00 | 59.94 | 59.92 | 60.0, 60.0 | 17.5 | 2.4 | 0 | 71 | 2.88 | 278 | 62.8 |
| fcr-pgo1 | 2/2 | 59.85 | 57.65 | 56.65 | 59.2, 60.0 | 18.5 | 4.3 | 2 | 71 | 2.08 | 289 | 63.9 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel11 | 150 | Flycast-emu 60, retroarch 57, deadcast-aica 15, mali-cmar-backe 10, deadcast-parse 6 | 15 | 46 |
| fcr-pgo1 | 170 | retroarch 74, Flycast-emu 62, deadcast-aica 15, mali-cmar-backe 10, deadcast-parse 8 | 16 | 51 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel11 | 2/2 | 60.10 | 59.91 | 59.88 | 60.1, 60.1 | 17.4 | 0.7 | 0 | 53 | 1.83 | 247 | 61.7 |
| fcr-pgo1 | 2/2 | 60.02 | 59.95 | 59.88 | 60.0, 60.1 | 17.4 | 0.6 | 0 | 53 | 2.33 | 244 | 61.1 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel11 | 132 | Flycast-emu 57, retroarch 46, deadcast-aica 11, mali-cmar-backe 10, deadcast-parse 5 | 16 | 42 |
| fcr-pgo1 | 130 | Flycast-emu 57, retroarch 46, deadcast-aica 10, mali-cmar-backe 10, deadcast-parse 5 | 16 | 42 |

### Each arm against fcr-rel11 (no worse = pass)

- crazy-taxi fcr-pgo1: median fps FAIL (59.85 vs 60.00); frame p95 FAIL (18.5 vs 17.5 ms); underruns FAIL (4.3 vs 2.4 %); startup pass (2.08 vs 2.88 s)
- sa2 fcr-pgo1: median fps FAIL (60.02 vs 60.10); frame p95 pass (17.4 vs 17.4 ms); underruns pass (0.6 vs 0.7 %); startup pass (2.33 vs 1.83 s)
