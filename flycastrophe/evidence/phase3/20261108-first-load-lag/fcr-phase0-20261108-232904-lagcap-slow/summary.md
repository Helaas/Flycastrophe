Mode: uncapped=0 drive=1 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-b37 | 2/2 | 59.92 | 53.29 | 47.62 | 59.9, 60.0 | 28.2 | 1.2 | 71 | 60 | 3.51 | 258 | 55.0 |
| fcr-lagcap | 2/2 | 58.99 | 30.54 | 26.52 | 34.0, 59.7 | 33.9 | 2.9 | 358 | 51 | 3.13 | 281 | 55.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-b37 | 190 | Flycast-emu 84, retroarch 62, deadcast-aica 22, mali-cmar-backe 12, deadcast-parse 7 | 20 | 58 |
| fcr-lagcap | 207 | Flycast-emu 89, retroarch 76, deadcast-aica 22, mali-cmar-backe 11, deadcast-parse 8 | 18 | 62 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-b37 | 2/2 | 53.17 | 26.48 | 24.19 | 32.2, 60.0 | 34.0 | 0.8 | 504 | 45 | 2.23 | 260 | 55.0 |
| fcr-lagcap | 2/2 | 60.00 | 59.72 | 59.70 | 60.0, 60.0 | 18.1 | 1.2 | 4 | 52 | 2.50 | 246 | 55.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-b37 | 191 | Flycast-emu 92, retroarch 62, deadcast-aica 17, mali-cmar-backe 10, deadcast-parse 8 | 17 | 58 |
| fcr-lagcap | 203 | Flycast-emu 89, retroarch 72, deadcast-aica 18, mali-cmar-backe 13, deadcast-parse 9 | 21 | 62 |

### Each arm against fcr-b37 (no worse = pass)

- crazy-taxi fcr-lagcap: median fps FAIL (58.99 vs 59.92); frame p95 FAIL (33.9 vs 28.2 ms); underruns FAIL (2.9 vs 1.2 %); startup pass (3.13 vs 3.51 s)
- sa2 fcr-lagcap: median fps pass (60.00 vs 53.17); frame p95 pass (18.1 vs 34.0 ms); underruns FAIL (1.2 vs 0.8 %); startup pass (2.50 vs 2.23 s)
