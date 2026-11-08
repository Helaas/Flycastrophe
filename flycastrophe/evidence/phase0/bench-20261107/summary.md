
### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 3/3 | 59.96 | 51.87 | 50.29 | 56.9, 60.0, 60.0 | 17.4 | 11.9 | 7 | 67 | 1.39 | 277 | 65.0 |
| vk | 3/3 | 59.52 | 54.27 | 53.95 | 60.0, 60.0, 54.8 | 17.9 | 17.8 | 13 | 68 | 2.00 | 255 | 65.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 169 | Flycast-emu 93, retroarch 64, mali-cmar-backe 10, threaded-ml 1 | 17 | 51 |
| vk | 159 | Flycast-emu 95, retroarch 54, mali-cmar-backe 7, threaded-ml 2 | 17 | 49 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 3/3 | 59.17 | 54.34 | 53.37 | 59.5, 58.8, 59.5 | 19.3 | 5.0 | 10 | 49 | 1.39 | 307 | 65.0 |
| vk | 3/3 | 59.83 | 52.43 | 50.10 | 60.0, 59.8, 59.3 | 19.9 | 3.5 | 9 | 57 | 2.33 | 268 | 64.4 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 174 | Flycast-emu 97, retroarch 66, mali-cmar-backe 10, threaded-ml 2 | 18 | 54 |
| vk | 155 | Flycast-emu 97, retroarch 49, mali-cmar-backe 7, threaded-ml 2 | 19 | 49 |

### Gate (Phase 0 step 6, numbers part)

- crazy-taxi: median fps FAIL (59.52 vs 59.96); frame p95 FAIL (17.9 vs 17.4 ms); underruns FAIL (17.8 vs 11.9 %); startup pass (2.00 vs 1.39 s)
- sa2: median fps pass (59.83 vs 59.17); frame p95 FAIL (19.9 vs 19.3 ms); underruns pass (3.5 vs 5.0 %); startup pass (2.33 vs 1.39 s)
