Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel11 | 2/2 | 60.06 | 59.89 | 59.85 | 60.1, 60.1 | 17.3 | 0.5 | 0 | 61 | 2.47 | 243 | 64.4 |
| fcr-pgo1 | 2/2 | 60.00 | 59.88 | 59.88 | 60.0, 60.0 | 17.2 | 0.6 | 0 | 57 | 2.15 | 242 | 65.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel11 | 178 | retroarch 80, Flycast-emu 64, deadcast-aica 13, mali-cmar-backe 10, deadcast-parse 10 | 16 | 53 |
| fcr-pgo1 | 173 | retroarch 77, Flycast-emu 63, deadcast-aica 12, mali-cmar-backe 10, deadcast-parse 9 | 15 | 51 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-rel11 | 2/2 | 60.04 | 59.88 | 59.88 | 60.1, 60.0 | 17.4 | 0.3 | 0 | 49 | 2.09 | 228 | 63.9 |
| fcr-pgo1 | 2/2 | 60.04 | 59.91 | 59.88 | 60.0, 60.0 | 17.4 | 0.3 | 0 | 49 | 2.10 | 226 | 62.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-rel11 | 147 | Flycast-emu 61, retroarch 57, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 15 | 44 |
| fcr-pgo1 | 144 | Flycast-emu 60, retroarch 55, deadcast-aica 10, mali-cmar-backe 10, deadcast-parse 8 | 15 | 44 |

### Each arm against fcr-rel11 (no worse = pass)

- crazy-taxi fcr-pgo1: median fps FAIL (60.00 vs 60.06); frame p95 pass (17.2 vs 17.3 ms); underruns FAIL (0.6 vs 0.5 %); startup pass (2.15 vs 2.47 s)
- sa2 fcr-pgo1: median fps FAIL (60.04 vs 60.04); frame p95 pass (17.4 vs 17.4 ms); underruns pass (0.3 vs 0.3 %); startup pass (2.10 vs 2.09 s)
