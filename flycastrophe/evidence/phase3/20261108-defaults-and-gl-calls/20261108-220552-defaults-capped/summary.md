Mode: uncapped=0 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-optold | 1/1 | 60.10 | 59.87 | 59.81 | 60.1 | 17.4 | 0.8 | 0 | 54 | 1.75 | 238 | 67.5 |
| fcr-optnew | 1/1 | 60.04 | 59.98 | 59.96 | 60.0 | 17.3 | 0.5 | 0 | 53 | 1.67 | 238 | 66.2 |
| fcr-optnodelay | 1/1 | 59.92 | 59.89 | 59.88 | 59.9 | 17.2 | 0.7 | 0 | 53 | 1.68 | 238 | 66.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-optold | 190 | retroarch 85, Flycast-emu 63, deadcast-aica 21, deadcast-parse 10, mali-cmar-backe 10 | 16 | 56 |
| fcr-optnew | 177 | retroarch 79, Flycast-emu 64, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 9 | 16 | 52 |
| fcr-optnodelay | 178 | retroarch 80, Flycast-emu 64, deadcast-aica 13, deadcast-parse 10, mali-cmar-backe 10 | 16 | 53 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-optold | 1/1 | 60.08 | 59.90 | 59.88 | 60.1 | 17.5 | 0.3 | 0 | 42 | 1.77 | 226 | 65.6 |
| fcr-optnew | 1/1 | 60.00 | 59.91 | 59.88 | 60.0 | 17.5 | 0.3 | 1 | 41 | 1.83 | 230 | 64.4 |
| fcr-optnodelay | 1/1 | 60.02 | 59.89 | 59.88 | 60.0 | 17.4 | 0.3 | 0 | 41 | 2.32 | 230 | 64.4 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-optold | 161 | retroarch 61, Flycast-emu 61, deadcast-aica 20, mali-cmar-backe 9, deadcast-parse 9 | 16 | 48 |
| fcr-optnew | 149 | Flycast-emu 61, retroarch 58, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 16 | 45 |
| fcr-optnodelay | 148 | Flycast-emu 61, retroarch 58, deadcast-aica 11, mali-cmar-backe 9, deadcast-parse 8 | 15 | 45 |

### Each arm against fcr-optold (no worse = pass)

- crazy-taxi fcr-optnew: median fps FAIL (60.04 vs 60.10); frame p95 pass (17.3 vs 17.4 ms); underruns pass (0.5 vs 0.8 %); startup pass (1.67 vs 1.75 s)
- crazy-taxi fcr-optnodelay: median fps FAIL (59.92 vs 60.10); frame p95 pass (17.2 vs 17.4 ms); underruns pass (0.7 vs 0.8 %); startup pass (1.68 vs 1.75 s)
- sa2 fcr-optnew: median fps FAIL (60.00 vs 60.08); frame p95 FAIL (17.5 vs 17.5 ms); underruns pass (0.3 vs 0.3 %); startup pass (1.83 vs 1.77 s)
- sa2 fcr-optnodelay: median fps FAIL (60.02 vs 60.08); frame p95 pass (17.4 vs 17.5 ms); underruns pass (0.3 vs 0.3 %); startup pass (2.32 vs 1.77 s)
