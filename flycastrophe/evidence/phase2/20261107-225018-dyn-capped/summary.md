Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr08 | 1/1 | 60.04 | 60.00 | 60.00 | 60.0 | 17.4 | 0.5 | 0 | 54 | 1.35 | 224 | 69.4 |
| fcr-dyn | 1/1 | 60.00 | 59.91 | 59.88 | 60.0 | 17.2 | 0.6 | 0 | 54 | 1.45 | 234 | 68.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr08 | 193 | retroarch 81, Flycast-emu 78, deadcast-aica 13, mali-cmar-backe 9, deadcast-parse 9 | 16 | 57 |
| fcr-dyn | 175 | retroarch 80, Flycast-emu 61, deadcast-aica 13, mali-cmar-backe 9, deadcast-parse 9 | 15 | 52 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-pr08 | 1/1 | 59.96 | 59.84 | 59.81 | 60.0 | 17.5 | 0.4 | 0 | 41 | 1.77 | 220 | 66.9 |
| fcr-dyn | 1/1 | 60.04 | 60.01 | 60.00 | 60.0 | 17.3 | 0.5 | 0 | 41 | 1.45 | 222 | 66.9 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-pr08 | 163 | Flycast-emu 76, retroarch 57, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 16 | 49 |
| fcr-dyn | 147 | Flycast-emu 60, retroarch 58, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 16 | 44 |

### Each arm against fcr-pr08 (no worse = pass)

- crazy-taxi fcr-dyn: median fps FAIL (60.00 vs 60.04); frame p95 pass (17.2 vs 17.4 ms); underruns FAIL (0.6 vs 0.5 %); startup pass (1.45 vs 1.35 s)
- sa2 fcr-dyn: median fps pass (60.04 vs 59.96); frame p95 pass (17.3 vs 17.5 ms); underruns FAIL (0.5 vs 0.4 %); startup pass (1.45 vs 1.77 s)
