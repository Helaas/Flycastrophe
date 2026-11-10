Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dcbase | 3/3 | 73.06 | 70.16 | 69.67 | 74.2, 72.0, 73.6 | 14.7 | 0.2 | 0 | 65 | 1.08 | 241 | 73.9 |
| fcr-dc0 | 3/3 | 71.33 | 68.99 | 68.71 | 71.1, 71.5, 69.9 | 15.0 | 0.2 | 0 | 63 | 1.12 | 238 | 73.3 |
| fcr-dcR | 3/3 | 87.27 | 85.85 | 84.73 | 87.4, 87.7, 86.8 | 12.4 | 0.1 | 0 | 77 | 1.11 | 236 | 76.2 |
| fcr-dcRM | 3/3 | 86.86 | 85.35 | 84.70 | 86.9, 87.3, 86.5 | 12.6 | 0.1 | 0 | 77 | 1.15 | 239 | 76.2 |
| fcr-dcRMG | 3/3 | 87.87 | 83.93 | 83.30 | 88.8, 88.0, 84.5 | 14.6 | 0.1 | 0 | 82 | 1.10 | 238 | 76.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dcbase | 205 | retroarch 98, Flycast-emu 65, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 18 | 61 |
| fcr-dc0 | 201 | retroarch 99, Flycast-emu 62, deadcast-aica 16, deadcast-parse 12, mali-cmar-backe 11 | 18 | 60 |
| fcr-dcR | 225 | retroarch 98, Flycast-emu 78, deadcast-aica 19, deadcast-parse 15, mali-cmar-backe 14 | 19 | 66 |
| fcr-dcRM | 225 | retroarch 98, Flycast-emu 78, deadcast-aica 19, deadcast-parse 15, mali-cmar-backe 14 | 19 | 66 |
| fcr-dcRMG | 222 | retroarch 94, Flycast-emu 77, deadcast-aica 19, deadcast-parse 16, mali-cmar-backe 14 | 20 | 66 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| fcr-dcbase | 3/3 | 98.37 | 95.97 | 95.97 | 100.7, 96.9, 98.4 | 11.0 | 0.2 | 0 | 67 | 1.13 | 228 | 76.2 |
| fcr-dc0 | 3/3 | 96.26 | 94.35 | 93.86 | 96.7, 96.3, 94.9 | 11.2 | 0.1 | 0 | 65 | 1.08 | 227 | 75.6 |
| fcr-dcR | 3/3 | 112.54 | 110.36 | 110.33 | 113.0, 112.8, 112.2 | 10.7 | 0.1 | 0 | 76 | 1.10 | 229 | 76.9 |
| fcr-dcRM | 3/3 | 112.05 | 110.12 | 109.73 | 112.8, 110.7, 111.4 | 10.7 | 0.1 | 0 | 76 | 1.07 | 229 | 76.9 |
| fcr-dcRMG | 3/3 | 110.62 | 108.42 | 108.40 | 112.5, 110.6, 109.9 | 12.3 | 0.1 | 0 | 81 | 1.10 | 233 | 77.5 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| fcr-dcbase | 233 | retroarch 98, Flycast-emu 86, deadcast-aica 18, mali-cmar-backe 15, deadcast-parse 14 | 19 | 68 |
| fcr-dc0 | 227 | retroarch 98, Flycast-emu 81, deadcast-aica 18, deadcast-parse 14, mali-cmar-backe 14 | 19 | 66 |
| fcr-dcR | 243 | Flycast-emu 98, retroarch 88, deadcast-aica 20, mali-cmar-backe 17, deadcast-parse 17 | 20 | 71 |
| fcr-dcRM | 242 | Flycast-emu 98, retroarch 89, deadcast-aica 20, mali-cmar-backe 17, deadcast-parse 17 | 20 | 71 |
| fcr-dcRMG | 241 | Flycast-emu 97, retroarch 89, deadcast-aica 20, deadcast-parse 17, mali-cmar-backe 17 | 20 | 71 |

### Uncapped: each arm relative to fcr-dcbase

- crazy-taxi fcr-dc0: median fps 71.33 vs 73.06 (-2.4%), p5 68.99 vs 70.16 (-1.7%), frame p95 15.0 vs 14.7 ms
- crazy-taxi fcr-dcR: median fps 87.27 vs 73.06 (+19.5%), p5 85.85 vs 70.16 (+22.4%), frame p95 12.4 vs 14.7 ms
- crazy-taxi fcr-dcRM: median fps 86.86 vs 73.06 (+18.9%), p5 85.35 vs 70.16 (+21.7%), frame p95 12.6 vs 14.7 ms
- crazy-taxi fcr-dcRMG: median fps 87.87 vs 73.06 (+20.3%), p5 83.93 vs 70.16 (+19.6%), frame p95 14.6 vs 14.7 ms
- sa2 fcr-dc0: median fps 96.26 vs 98.37 (-2.1%), p5 94.35 vs 95.97 (-1.7%), frame p95 11.2 vs 11.0 ms
- sa2 fcr-dcR: median fps 112.54 vs 98.37 (+14.4%), p5 110.36 vs 95.97 (+15.0%), frame p95 10.7 vs 11.0 ms
- sa2 fcr-dcRM: median fps 112.05 vs 98.37 (+13.9%), p5 110.12 vs 95.97 (+14.7%), frame p95 10.7 vs 11.0 ms
- sa2 fcr-dcRMG: median fps 110.62 vs 98.37 (+12.5%), p5 108.42 vs 95.97 (+13.0%), frame p95 12.3 vs 11.0 ms
