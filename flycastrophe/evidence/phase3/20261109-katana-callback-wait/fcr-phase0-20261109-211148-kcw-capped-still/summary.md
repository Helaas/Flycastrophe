Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-glboth2 | 2/2 | 60.04 | 59.91 | 59.85 | 60.0, 60.1 | 17.3 | 0.7 | 0 | 60 | 2.17 | 253 | 70.0 |
| fcr-kcw1 | 2/2 | 60.04 | 59.88 | 59.88 | 60.0, 60.0 | 17.2 | 0.6 | 0 | 61 | 2.45 | 253 | 69.4 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-glboth2 | 176 | retroarch 78, Flycast-emu 64, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 9 | 15 | 52 |
| fcr-kcw1 | 164 | retroarch 78, Flycast-emu 53, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 9 | 15 | 49 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-glboth2 | 2/2 | 60.04 | 59.93 | 59.88 | 60.1, 60.0 | 17.4 | 0.3 | 0 | 48 | 2.33 | 239 | 67.5 |
| fcr-kcw1 | 2/2 | 60.00 | 59.95 | 59.88 | 60.0, 60.0 | 17.3 | 0.3 | 0 | 48 | 1.81 | 240 | 66.9 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-glboth2 | 147 | Flycast-emu 60, retroarch 57, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 16 | 45 |
| fcr-kcw1 | 134 | retroarch 56, Flycast-emu 48, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 15 | 41 |

### Each arm against fcr-glboth2 (no worse = pass)

- crazy-taxi fcr-kcw1: median fps pass (60.04 vs 60.04); frame p95 pass (17.2 vs 17.3 ms); underruns pass (0.6 vs 0.7 %); startup pass (2.45 vs 2.17 s)
- sa2 fcr-kcw1: median fps FAIL (60.00 vs 60.04); frame p95 pass (17.3 vs 17.4 ms); underruns pass (0.3 vs 0.3 %); startup pass (1.81 vs 2.33 s)
