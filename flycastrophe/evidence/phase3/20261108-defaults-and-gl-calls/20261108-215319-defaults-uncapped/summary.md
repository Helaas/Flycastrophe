Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-optold | 2/2 | 67.75 | 66.78 | 66.60 | 67.6, 68.0 | 15.8 | 0.3 | 0 | 61 | 1.40 | 245 | 67.5 |
| fcr-optnew | 2/2 | 71.21 | 69.24 | 69.02 | 71.5, 71.1 | 15.1 | 0.3 | 0 | 63 | 1.42 | 249 | 66.9 |
| fcr-optnodelay | 2/2 | 70.08 | 67.78 | 67.43 | 70.7, 69.2 | 15.3 | 0.3 | 0 | 62 | 1.37 | 249 | 65.6 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-optold | 220 | retroarch 98, Flycast-emu 74, deadcast-aica 24, deadcast-parse 11, mali-cmar-backe 11 | 17 | 64 |
| fcr-optnew | 215 | retroarch 98, Flycast-emu 77, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 18 | 63 |
| fcr-optnodelay | 214 | retroarch 99, Flycast-emu 75, deadcast-aica 15, deadcast-parse 12, mali-cmar-backe 11 | 17 | 63 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-optold | 2/2 | 88.12 | 86.82 | 86.56 | 88.2, 88.0 | 12.8 | 0.1 | 0 | 61 | 1.49 | 228 | 70.0 |
| fcr-optnew | 2/2 | 88.72 | 88.07 | 87.98 | 89.1, 88.7 | 12.3 | 0.1 | 0 | 60 | 1.74 | 231 | 70.0 |
| fcr-optnodelay | 2/2 | 90.43 | 89.96 | 89.87 | 90.3, 90.6 | 12.2 | 0.1 | 0 | 61 | 1.74 | 227 | 68.8 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-optold | 251 | Flycast-emu 97, retroarch 94, deadcast-aica 31, mali-cmar-backe 14, deadcast-parse 13 | 18 | 72 |
| fcr-optnew | 234 | Flycast-emu 99, retroarch 89, deadcast-aica 16, mali-cmar-backe 15, deadcast-parse 13 | 18 | 68 |
| fcr-optnodelay | 231 | Flycast-emu 99, retroarch 88, deadcast-aica 17, mali-cmar-backe 13, deadcast-parse 13 | 18 | 67 |

### Uncapped: each arm relative to fcr-optold

- crazy-taxi fcr-optnew: median fps 71.21 vs 67.75 (+5.1%), p5 69.24 vs 66.78 (+3.7%), frame p95 15.1 vs 15.8 ms
- crazy-taxi fcr-optnodelay: median fps 70.08 vs 67.75 (+3.4%), p5 67.78 vs 66.78 (+1.5%), frame p95 15.3 vs 15.8 ms
- sa2 fcr-optnew: median fps 88.72 vs 88.12 (+0.7%), p5 88.07 vs 86.82 (+1.4%), frame p95 12.3 vs 12.8 ms
- sa2 fcr-optnodelay: median fps 90.43 vs 88.12 (+2.6%), p5 89.96 vs 86.82 (+3.6%), frame p95 12.2 vs 12.8 ms
