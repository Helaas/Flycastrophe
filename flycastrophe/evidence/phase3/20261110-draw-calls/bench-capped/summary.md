Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dcbase | 1/1 | 60.04 | 59.90 | 59.88 | 60.0 | 17.3 | 0.3 | 0 | 54 | 1.45 | 233 | 68.1 |
| fcr-prfinal | 1/1 | 60.04 | 59.97 | 59.96 | 60.0 | 17.6 | 0.3 | 0 | 54 | 1.47 | 231 | 66.9 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dcbase | 165 | retroarch 80, Flycast-emu 52, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 10 | 16 | 49 |
| fcr-prfinal | 150 | retroarch 63, Flycast-emu 52, deadcast-aica 13, mali-cmar-backe 10, deadcast-parse 10 | 15 | 45 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dcbase | 1/1 | 60.02 | 59.91 | 59.88 | 60.0 | 17.5 | 0.5 | 0 | 41 | 1.41 | 225 | 65.0 |
| fcr-prfinal | 1/1 | 60.00 | 59.91 | 59.88 | 60.0 | 17.5 | 0.4 | 0 | 41 | 1.46 | 222 | 64.4 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dcbase | 134 | retroarch 57, Flycast-emu 47, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 16 | 41 |
| fcr-prfinal | 121 | Flycast-emu 48, retroarch 43, deadcast-aica 11, mali-cmar-backe 10, deadcast-parse 9 | 16 | 38 |

### Each arm against fcr-dcbase (no worse = pass)

- crazy-taxi fcr-prfinal: median fps pass (60.04 vs 60.04); frame p95 FAIL (17.6 vs 17.3 ms); underruns FAIL (0.3 vs 0.3 %); startup pass (1.47 vs 1.45 s)
- sa2 fcr-prfinal: median fps FAIL (60.00 vs 60.02); frame p95 pass (17.5 vs 17.5 ms); underruns pass (0.4 vs 0.5 %); startup pass (1.46 vs 1.41 s)
