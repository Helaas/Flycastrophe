Mode: uncapped=1 drive=0 warmup=10s window=30s

### crazy-taxi

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 3/3 | 58.85 | 57.79 | 57.69 | 58.8, 59.3, 58.8 | 18.2 | 9.5 | 2 | 53 | 1.12 | 233 | 67.5 |
| vk | 3/3 | 58.19 | 57.10 | 57.03 | 58.0, 58.1, 58.6 | 18.0 | 21.8 | 0 | 54 | 1.77 | 247 | 66.2 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 204 | Flycast-emu 98, retroarch 94, mali-cmar-backe 10, threaded-ml 2 | 18 | 61 |
| vk | 174 | Flycast-emu 99, retroarch 65, mali-cmar-backe 8, threaded-ml 2 | 19 | 54 |

### sa2

| RetroArch | reps ok | fps median | fps p5 | fps min | rep medians | frame p95 ms | underrun % | dropped | GPU load % | startup s | RSS MB | max °C |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gles | 3/3 | 62.04 | 60.43 | 60.23 | 62.8, 62.0, 60.8 | 17.2 | 1.3 | 0 | 43 | 1.13 | 233 | 66.2 |
| vk | 3/3 | 60.77 | 59.78 | 59.65 | 61.2, 60.5, 60.7 | 17.2 | 4.4 | 0 | 52 | 2.06 | 251 | 65.0 |

CPU over the window, percent of one core (mean of reps):

| RetroArch | RetroArch total | busiest threads | Weston | SoC busy (of 4 cores) |
| --- | ---: | --- | ---: | ---: |
| gles | 185 | Flycast-emu 100, retroarch 73, mali-cmar-backe 11, threaded-ml 2 | 18 | 56 |
| vk | 164 | Flycast-emu 99, retroarch 55, mali-cmar-backe 8, threaded-ml 2 | 20 | 51 |

### Uncapped: Vulkan relative to GLES

- crazy-taxi: median fps 58.19 vs 58.85 (-1.1%), p5 57.10 vs 57.79 (-1.2%), frame p95 18.0 vs 18.2 ms
- sa2: median fps 60.77 vs 62.04 (-2.1%), p5 59.78 vs 60.43 (-1.1%), frame p95 17.2 vs 17.2 ms
