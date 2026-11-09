# The Katana library's callback wait (2026-11-09)

The profiles in [20261109-gl-overhead](../20261109-gl-overhead/) found the same loop as the hottest
SH4 code in Sonic Adventure 2 and Crazy Taxi (66% and 53% of their guest cycles): a wait for a flag
to clear that calls an idle callback each turn, with a timeout on a counter. Deadcast's wait-loop
skipping knows the Katana library's other wait (the vblank counter, slot 7 of its callback table)
but not this one. `core/deadcast/waitloops.cpp` now recognizes it too: the loop's code with the
PC-relative literals' offsets left open, the head block hooked, and at each turn the callback
checked to still be a no-op (`rts; nop`) and the flag, counters and callback slot to be in main
RAM. While the flag is set and the timeout isn't reached, the SH4's time goes by as the turns
would make it go (`passTurns`), so the game's timing doesn't change: an interrupt still lands at
the next timeslice, and the flag and counters are read again after every scheduler event.

## Bench

Dev builds of fork `main` (`2a1cb3bd`) without PGO: `fcr-glboth2` = main, `fcr-kcw1` = main plus
the new wait. Bench core options, performance governors, order rotating.

**Uncapped still scenes, 3 rounds** (`*-kcw-uncapped`):

| Game | fcr-glboth2 fps (rounds) | fcr-kcw1 fps (rounds) | Change |
| --- | --- | --- | --- |
| SA2 | 91.99 (92.1, 91.2, 92.1) | 99.81 (101.0, 99.9, 99.0) | +8.5% |
| Crazy Taxi | 71.84 (72.8, 70.9, 71.8) | 73.16 (74.0, 72.1, 73.8) | +1.8% (rounds overlap) |

SA2 was limited by the emulation thread (98%); with the loop skipped it's limited by RetroArch's
thread (98%) instead. Crazy Taxi was and stays limited by RetroArch's thread; its emulation
thread went from 78% to 66% of a core.

**Capped still scenes, audio on, 2 rounds** (`*-kcw-capped-still`): both hold 60 fps with the same
frame p95 and underruns. The emulation thread: Crazy Taxi 64% to 53% of a core, SA2 60% to 48%;
the SoC 52% to 49% and 45% to 41% busy.

## Which games have it (`gameplay-check.txt`)

`fcr-kcw1` on the card's discs, 40 s from a state (with a generic input loop) or 50 s from the BIOS
(Start and A pressed): Leaf's RetroArch with the bench config, game governors, `FLYCASTROPHE_PERF=1`.

| Game | Wait matched | Result |
| --- | --- | --- |
| Sonic Adventure 2, Crazy Taxi | the callback wait | the bench above |
| Sonic Adventure (#1600's state) | the callback wait, at 8c642058 | cutscene plays on, 59 vblanks/s |
| Power Stone (boot) | the callback wait, at 0c0f5dd8 | to the character select, 61 vblanks/s |
| Spider-Man (three states) | the vblank wait (Deadcast's) | plays, 60-61 vblanks/s |
| Dead or Alive 2 (boot) | the vblank wait (Deadcast's) | to its "initializing" screen in 50 s |
| Ecco the Dolphin (#1610's state) | neither | plays, 62 vblanks/s |

No errors or aborts in any log. A short check, not a playthrough.
