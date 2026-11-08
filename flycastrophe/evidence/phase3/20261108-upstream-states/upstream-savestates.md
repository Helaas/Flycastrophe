# Savestates attached to upstream Flycast issues

Scanned 2026-11-08: every issue, pull request and comment in [flyinghead/flycast](https://github.com/flyinghead/flycast/issues) (2,435 issues and PRs, 7,839 comments) for attachment links, keeping those that are savestates by name or by what the post says. The ten on the share were downloaded and tried on the device the same day (below). The states themselves aren't in this repository: they're other people's saves of commercial games; the working copy is in the UMRK workspace's `tmp/flycastrophe-pgo/`.

- **Format:** standalone Flycast states are a `FLYSAVE1` header (with the state version), an optional PNG and the state compressed with Flycast's RZip; RetroArch's are a `RASTATE` container. The libretro core loads both kinds of payload once a standalone file is unpacked (header and PNG stripped, RZip decompressed).
- **Version:** the core loads state versions V16 (November 2021) and newer; anything posted before that is marked too old.
- **Share:** whether `/Volumes/home/Roms` has that game in the same region. A state only loads against the same disc.
- **Fit:** what the scene is good for. States that sit on a crash, freeze, hang or disc swap make poor training runs.

## Summary

69 savestates in 45 issues. Ten are for games on the share in a matching region, all hosted on GitHub, about 89 MB together:

| Issue | Game | Scene | File size |
| --- | --- | --- | ---: |
| #2191 | Spider-Man (USA) | later levels, several states | 13.7 MB |
| #1778 | Sonic Adventure 2 (USA) | Knuckles gliding | 9.3 MB |
| #1684 | Phantasy Star Online Ver. 2 (USA) | gameplay | 10.0 MB |
| #1610 | L.O.L. - Lack of Love (Japan) | explosions and smoke | 9.4 MB |
| #1610 | Ecco the Dolphin: Defender of the Future (USA) | heavy transparency | 10.9 MB |
| #1610 | Tech Romancer | fight | 8.6 MB |
| #1610 | Vigilante 8: 2nd Offense (USA) | combat | 5.9 MB |
| #1600 | Sonic Adventure (USA, Rev A) | Station Square cutscene | 8.8 MB |
| #1284 | Evolution 2: Far Off Promise (USA) | battle | 7.7 MB |
| #1033 | L.O.L. - Lack of Love (Japan) | gameplay | 4.6 MB |

Same region isn't proof of the same disc: a state from a different revision can crash on load. Soulcalibur, Shenmue, Army Men and Capcom vs. SNK are on the share in another region only. Most of the rest are games the share doesn't have; #1610 alone has 17 states of transparency-heavy scenes.

## Downloaded (2026-11-08)

The ten files above, in `downloads/<issue>-<attachment id>/`, unpacked by `tools/unpack_inspect.py` into `extracted/`, with each state's raw core data beside it as `<name>.raw.state` (RetroArch loads a header-less state as is). Twelve states: the Spider-Man zip holds three.

| Issue | State | Made with | Version |
| --- | --- | --- | --- |
| #2191 | Spider-Man (USA), three states | standalone (FLYSAVE1, RZip) | V56 |
| #1778 | Sonic Adventure 2 v1.008 (US) | standalone (FLYSAVE1, RZip) | V51 |
| #1684 | Phantasy Star Online Ver. 2 (USA) | RetroArch (RASTATE, RetroArch's RZip) | V51 |
| #1610 | L.O.L. - Lack of Love | standalone (FLYSAVE1, RZip) | V51 |
| #1610 | Ecco the Dolphin (USA) | standalone (FLYSAVE1, RZip) | V51 |
| #1610 | Tech Romancer | standalone (FLYSAVE1, RZip) | V51 |
| #1610 | Vigilante 8: 2nd Offense v1.000 (US) | standalone (FLYSAVE1, RZip) | V51 |
| #1600 | Sonic Adventure (USA) (Rev A), slot 3 | RetroArch (RASTATE, RetroArch's RZip) | V51 |
| #1284 | Evolution 2 v1.000 (US) | RZip without a header | V42 |
| #1033 | L.O.L. - Lack of Love | RZip without a header | V31 |

All are versions the fork loads (V16 to V59). Whether each loads against the share's disc is still to be tried on the device.

## Tried on the device (2026-11-08)

Each raw state loaded as `<disc>.state.auto` with the Flycastrophe release build (`fcr-rel`, fork `115dd9d`) in Leaf's RetroArch, bench config, against the share's disc (`tools/trystates.sh`, logs and frames in `trystates*/`, the 20 s frames tiled in `tried-on-device-20s.jpg`):

| State | Disc | Result |
| --- | --- | --- |
| #2191 Spider-Man, three states | Spider-Man (USA) | all three play |
| #1778 Sonic Adventure 2 | Sonic Adventure 2 (USA) | plays (Knuckles) |
| #1684 Phantasy Star Online Ver. 2 | PSO Ver. 2 (USA) | plays |
| #1610 L.O.L. | L.O.L. (Japan), and the English patch v1.001 | plays on both |
| #1610 Ecco the Dolphin | Ecco (USA) | plays |
| #1610 Tech Romancer | Tech Romancer (USA) | plays (a fight) |
| #1610 Vigilante 8: 2nd Offense | Vigilante 8 (USA) | plays |
| #1600 Sonic Adventure | Sonic Adventure (USA) (Rev A) | plays (Station Square cutscene) |
| #1284 Evolution 2 | Evolution 2 (USA) | plays (battle menu) |
| #1033 L.O.L. | L.O.L. (Japan), and the English patch | **RetroArch aborts on load**: "Fatal: SH4 branch instruction in delay slot" |

The #1033 crash is Flycastrophe's code cache, not the state: Leaf's stock Flycast plays it, and so does the release build once the L.O.L. block list from the #1610 session is removed. `rdv_Precompile` decodes each recorded block before checking that its code still matches, so an address that holds other code in this save can throw from the decoder, and nothing catches that on the way out of `retro_unserialize`. Builds from before the code cache (#6 and earlier) load it too.

Fixed in Helaas/Flycastrophe `agent/codecache-stale-blocks`: the warm-up checks each recorded block's size and hash before decoding it, and a decode error skips the block. With the fix both L.O.L. states play in either order (3361 and 4566 blocks compiled ahead, 173 and 140 stale ones skipped), where the release build aborted; Crazy Taxi and SA2 still compile 5905 and 7742 blocks ahead in the same time (`device-runs.txt`).

## All states

| Issue | Date | Game | Region | Scene | Fit | Format (guessed from the thread) | On the share | File |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [#2469](https://github.com/flyinghead/flycast/issues/2469) | 2026-09-04 | NBA 2K | USA | crowd cheering sound | gameplay | standalone | no | [NBA.2K.v1.008.1999.Sega.NTSC.US.state.zip](https://github.com/user-attachments/files/31829914/NBA.2K.v1.008.1999.Sega.NTSC.US.state.zip) |
| [#2191](https://github.com/flyinghead/flycast/issues/2191) | 2026-01-08 | Spider-Man | USA | later levels, texture clipping (several states) | gameplay | standalone | yes | [Spider-Man.USA.states.zip](https://github.com/user-attachments/files/24507012/Spider-Man.USA.states.zip) |
| [#2164](https://github.com/flyinghead/flycast/issues/2164) | 2025-12-18 | Street Fighter Zero 3 Saikyo-ryu Dojo | Japan | fight, custom textures | gameplay (needs its texture pack for the bug, not to run) | standalone | no | [Street.Fighter.Zero.3.-.Saikyo-ryu.Dojo.for.Matching.Service.Japan.state.zip](https://github.com/user-attachments/files/24237364/Street.Fighter.Zero.3.-.Saikyo-ryu.Dojo.for.Matching.Service.Japan.state.zip) |
| [#2044](https://github.com/flyinghead/flycast/issues/2044) | 2025-08-20 | Evil Twin: Cyprien's Chronicles | ? | ship area, crashes with the slingshot | avoid: crash | standalone | no | [evil.twin.saves.zip](https://github.com/user-attachments/files/21901745/evil.twin.saves.zip) |
| [#1903](https://github.com/flyinghead/flycast/issues/1903) | 2025-04-12 | unknown | ? | RetroArch Android states that fail to load | avoid: broken states | RetroArch | - | [states.zip](https://github.com/user-attachments/files/19722115/states.zip) |
| [#1812](https://github.com/flyinghead/flycast/issues/1812) | 2025-01-20 | Segagaga | Japan | replacement textures not loading | gameplay | standalone | no | [SGGG_State_Textures.zip](https://github.com/user-attachments/files/18478009/SGGG_State_Textures.zip) |
| [#1778](https://github.com/flyinghead/flycast/issues/1778) | 2024-12-15 | Sonic Adventure 2 | USA v1.008 | Knuckles gliding | gameplay | standalone | yes | [Sonic.Adventure.2.v1.008.2001.Sega.NTSC.US.M5.state.txt](https://github.com/user-attachments/files/18142060/Sonic.Adventure.2.v1.008.2001.Sega.NTSC.US.M5.state.txt) |
| [#1684](https://github.com/flyinghead/flycast/issues/1684) | 2024-10-11 | Phantasy Star Online Ver. 2 | USA | Z-fighting | gameplay | RetroArch | yes | [Phantasy.Star.Online.Ver.2.USA.En.Ja.Fr.De.Es.state.zip](https://github.com/user-attachments/files/17340776/Phantasy.Star.Online.Ver.2.USA.En.Ja.Fr.De.Es.state.zip) |
| [#1668](https://github.com/flyinghead/flycast/issues/1668) | 2024-10-07 | Soulcalibur | USA | battle loading screen | loading | RetroArch | Europe only | [Soulcalibur.save.state.issue.1.zip](https://github.com/user-attachments/files/17284298/Soulcalibur.save.state.issue.1.zip) |
| [#1668](https://github.com/flyinghead/flycast/issues/1668) | 2024-10-07 | Soulcalibur | USA | harbour stage, flag and sail | gameplay | RetroArch | Europe only | [Soulcalibur.save.state.issue.2.zip](https://github.com/user-attachments/files/17284374/Soulcalibur.save.state.issue.2.zip) |
| [#1667](https://github.com/flyinghead/flycast/issues/1667) | 2024-10-07 | NBA 2K2 | USA | end of game, freezes on exit | avoid: freeze | RetroArch | no | [NBA.2K2.save.state.zip](https://github.com/user-attachments/files/17284184/NBA.2K2.save.state.zip) |
| [#1652](https://github.com/flyinghead/flycast/issues/1652) | 2024-09-27 | Fighting Force 2 | USA | window background glitches | gameplay | standalone | no | [Fighting.Force.2.v1.000.1999.EIDOS.NTSC.US.state.zip](https://github.com/user-attachments/files/17165243/Fighting.Force.2.v1.000.1999.EIDOS.NTSC.US.state.zip) |
| [#1626](https://github.com/flyinghead/flycast/issues/1626) | 2024-09-02 | Mushiking (NAOMI: mushik2e etc.) | export | third round loading hang | avoid: hang | standalone | no | [savestate1.zip](https://github.com/user-attachments/files/16836791/savestate1.zip) |
| [#1626](https://github.com/flyinghead/flycast/issues/1626) | 2024-09-02 | Mushiking (NAOMI) | export | third round loading hang | avoid: hang | standalone | no | [savestate2.zip](https://github.com/user-attachments/files/16836792/savestate2.zip) |
| [#1621](https://github.com/flyinghead/flycast/issues/1621) | 2024-08-28 | Legacy of Kain: Soul Reaver | ? | stereo channels swapped | gameplay | standalone | no | [Soul.Reaver.reversed.stereo.save.state.tar.gz](https://github.com/user-attachments/files/16789178/Soul.Reaver.reversed.stereo.save.state.tar.gz) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-08-24 | L.O.L. - Lack of Love | Japan | explosions and smoke (48 transparency layers) | gameplay, heavy transparency | RetroArch | yes | [L.O.L.-.Lack.of.Love.state.zip](https://github.com/user-attachments/files/16735779/L.O.L.-.Lack.of.Love.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-08-24 | Gaiamaster Kessen! Seikioh Densetsu | Japan | 92 transparency layers | heavy transparency | RetroArch | no | [Gaiamaster.-.Kessen.Seikioh.Densetsu.zip](https://github.com/user-attachments/files/16736032/Gaiamaster.-.Kessen.Seikioh.Densetsu.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-08-24 | San Francisco Rush 2049 | USA | over 100 layers when accelerating into a wall | racing, heavy transparency | RetroArch | no | [San.Francisco.RUSH.2049.v1.001.2000.Midway.NTSC.US.state.zip](https://github.com/user-attachments/files/16735808/San.Francisco.RUSH.2049.v1.001.2000.Midway.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-08-24 | Conflict Zone | USA | 128 layers | heavy transparency | RetroArch | no | [Conflict.Zone.-.Modern.War.Strategy.v1.002.2001.Ubi.Soft.NTSC.US.state.zip](https://github.com/user-attachments/files/16735814/Conflict.Zone.-.Modern.War.Strategy.v1.002.2001.Ubi.Soft.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-08-24 | Ecco the Dolphin: Defender of the Future | USA | transparency layers | gameplay, heavy transparency | RetroArch | yes | [Ecco.the.Dolphin.-.Defender.of.the.Future.USA.En.Fr.De.Es.state.zip](https://github.com/user-attachments/files/16739623/Ecco.the.Dolphin.-.Defender.of.the.Future.USA.En.Fr.De.Es.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-17 | BANG! Gunship Elite | USA | 52 layers | heavy transparency | RetroArch | no | [BANG.-.Gunship.Elite.v1.003.2000.Red.Storm.NTSC.US.state.zip](https://github.com/user-attachments/files/17026063/BANG.-.Gunship.Elite.v1.003.2000.Red.Storm.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-17 | MDK 2 | USA | 110 layers | heavy transparency | RetroArch | no | [MDK.2.v1.100.2000.Interplay.NTSC.US.state.zip](https://github.com/user-attachments/files/17026070/MDK.2.v1.100.2000.Interplay.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-17 | Soldier of Fortune | USA | 56 layers | heavy transparency | RetroArch | no | [Soldier.of.Fortune.v1.001.2001.Crave.NTSC.US.state.zip](https://github.com/user-attachments/files/17026075/Soldier.of.Fortune.v1.001.2001.Crave.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-27 | Army Men: Sarge's Heroes | ? | over 128 layers | heavy transparency | RetroArch | Europe only | [Army.Men.-.Sarges.Heroes.zip](https://github.com/user-attachments/files/17165641/Army.Men.-.Sarges.Heroes.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-27 | Spirit of Speed 1937 | USA | 64 layers, accelerate | racing | RetroArch | no | [Spirit.of.Speed.1937.v1.001.2000.LJN.NTSC.US.state.zip](https://github.com/user-attachments/files/17166038/Spirit.of.Speed.1937.v1.001.2000.LJN.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-27 | Zombie Revenge | USA | 116 layers, turn your back to the enemy | gameplay, heavy transparency | RetroArch | no | [Zombie.Revenge.v1.001.1999.Sega.NTSC.US.state.zip](https://github.com/user-attachments/files/17165552/Zombie.Revenge.v1.001.1999.Sega.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-27 | Demolition Racer: No Exit | ? | 44 layers, crash two cars | racing | RetroArch | no | [Demolition.Racer.-.No.Exit.zip](https://github.com/user-attachments/files/17165583/Demolition.Racer.-.No.Exit.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-27 | Tech Romancer | ? | 56 layers, right trigger | fight | RetroArch | yes (USA) | [Tech.Romancer.zip](https://github.com/user-attachments/files/17165646/Tech.Romancer.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-27 | Vigilante 8: 2nd Offense | USA | 64 layers, flame the tree | gameplay | RetroArch | yes | [Vigilante.8.-.2nd.Offense.v1.000.1999.Activision.NTSC.US.state.zip](https://github.com/user-attachments/files/17165652/Vigilante.8.-.2nd.Offense.v1.000.1999.Activision.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-09-27 | Fighting Force 2 | USA | over 128 layers | heavy transparency | RetroArch | no | [Fighting.Force.2.v1.000.1999.EIDOS.NTSC.US.state.zip](https://github.com/user-attachments/files/17165656/Fighting.Force.2.v1.000.1999.EIDOS.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-10-04 | Evil Dead: Hail to the King | USA | over 128 layers | heavy transparency | RetroArch | no | [Evil.Dead.-.Hail.to.the.King.v1.002.2000.THQ.NTSC.US.state.zip](https://github.com/user-attachments/files/17252502/Evil.Dead.-.Hail.to.the.King.v1.002.2000.THQ.NTSC.US.state.zip) |
| [#1610](https://github.com/flyinghead/flycast/issues/1610) | 2024-10-04 | Nightmare Creatures II | USA | up to 117 layers, right trigger | heavy transparency | RetroArch | no | [Nightmare.Creatures.II.v1.000.2000.Konami.NTSC.US.state.zip](https://github.com/user-attachments/files/17252511/Nightmare.Creatures.II.v1.000.2000.Konami.NTSC.US.state.zip) |
| [#1609](https://github.com/flyinghead/flycast/issues/1609) | 2024-08-23 | Alone in the Dark: The New Nightmare | USA | walk to a cutscene | cutscene | RetroArch | no | [Alone.in.the.Dark.-.The.New.Nightmare.USA.zip](https://github.com/user-attachments/files/16726738/Alone.in.the.Dark.-.The.New.Nightmare.USA.zip) |
| [#1604](https://github.com/flyinghead/flycast/issues/1604) | 2024-08-20 | Time Stalkers | USA | final boss attack | gameplay | standalone | no | [TimeStalkers.v1.002.2000.Sega.NTSC.US.state.zip](https://github.com/user-attachments/files/16678136/TimeStalkers.v1.002.2000.Sega.NTSC.US.state.zip) |
| [#1602](https://github.com/flyinghead/flycast/issues/1602) | 2024-08-26 | Legacy of Kain: Soul Reaver | USA | reboot when loading certain areas | avoid: reboot | standalone | no | [Legacy.of.Kain.-.Soul.Reaver.v1.000.1999.EIDOS.NTSC.US.state.zip](https://github.com/user-attachments/files/16745444/Legacy.of.Kain.-.Soul.Reaver.v1.000.1999.EIDOS.NTSC.US.state.zip) |
| [#1600](https://github.com/flyinghead/flycast/issues/1600) | 2024-08-19 | Sonic Adventure | USA Rev A | Station Square cutscene | cutscene | RetroArch | yes | [Sonic.Adventure.Save.State.zip](https://github.com/user-attachments/files/16664186/Sonic.Adventure.Save.State.zip) |
| [#1481](https://github.com/flyinghead/flycast/issues/1481) | 2024-04-14 | NBA 2K2 | USA | freezes after a finished game | avoid: freeze | standalone | no | [NBA2K2.state.and.vmu.zip](https://github.com/flyinghead/flycast/files/14969517/NBA2K2.state.and.vmu.zip) |
| [#1399](https://github.com/flyinghead/flycast/issues/1399) | 2024-02-14 | Test Drive Le Mans | ? | end of 24-hour race, crashes after | avoid: crash | standalone | no | [Test.Drive.Le.Mans.zip](https://github.com/flyinghead/flycast/files/14288525/Test.Drive.Le.Mans.zip) |
| [#1387](https://github.com/flyinghead/flycast/issues/1387) | 2024-02-07 | Wild Riders (NAOMI 2) | Japan | transition effects | gameplay | standalone | no | [wldrider.savestate.zip](https://github.com/flyinghead/flycast/files/14199887/wldrider.savestate.zip) |
| [#1349](https://github.com/flyinghead/flycast/issues/1349) | 2023-12-17 | Sakura Wars 3 | Japan | walking part, conversation text | gameplay (2D-heavy) | standalone | no | [sakura3_save_state.zip](https://github.com/flyinghead/flycast/files/13697129/sakura3_save_state.zip) |
| [#1284](https://github.com/flyinghead/flycast/issues/1284) | 2023-11-05 | Evolution 2: Far Off Promise | USA | Giant Knuckle skill | battle | standalone | yes | [Evolution.2.-.Far.Off.Promise.v1.000.2000.Ubi.Soft.NTSC.US._4.state.zip](https://github.com/flyinghead/flycast/files/13260715/Evolution.2.-.Far.Off.Promise.v1.000.2000.Ubi.Soft.NTSC.US._4.state.zip) |
| [#1191](https://github.com/flyinghead/flycast/issues/1191) | 2023-09-09 | Capcom vs. SNK (Dreamcast) | Japan | winning KO, per-pixel sorting | fight | RetroArch | USA and Pro (Japan) only | [Capcom.vs.SNK.-.Millennium.Fight.2000.Japan.zip](https://github.com/flyinghead/flycast/files/12565264/Capcom.vs.SNK.-.Millennium.Fight.2000.Japan.zip) |
| [#1072](https://github.com/flyinghead/flycast/issues/1072) | 2023-05-18 | Bokomu no Tatsujin | Japan | screen transitions | gameplay | standalone | no | [Bokomu.no.Tatsujin.zip](https://github.com/flyinghead/flycast/files/11507776/Bokomu.no.Tatsujin.zip) |
| [#1066](https://github.com/flyinghead/flycast/issues/1066) | 2023-05-18 | D2 (disc 1) | ? | blackout with HLE BIOS | avoid: HLE-only bug | standalone | no | [D2.Disc.1.zip](https://github.com/flyinghead/flycast/files/11505848/D2.Disc.1.zip) |
| [#1064](https://github.com/flyinghead/flycast/issues/1064) | 2023-05-10 | Disney's Dinosaur | ? | coastline, unexpected jump | gameplay | standalone | no | [Dinosaur.zip](https://github.com/flyinghead/flycast/files/11441077/Dinosaur.zip) |
| [#1058](https://github.com/flyinghead/flycast/issues/1058) | 2026-10-10 | Kita he: White Illumination | Japan | opening, returns to BIOS | avoid: reset | standalone | no | [Kita.he.-.White.Illumination.zip](https://github.com/user-attachments/files/33272209/Kita.he.-.White.Illumination.zip) |
| [#1057](https://github.com/flyinghead/flycast/issues/1057) | 2023-05-06 | Soukou no Kihei Space Griffon | Japan | opening movie (HLE BIOS) | cutscene | standalone | no | [Soukou.no.Kihei.-.Space.Griffon.zip](https://github.com/flyinghead/flycast/files/11412359/Soukou.no.Kihei.-.Space.Griffon.zip) |
| [#1057](https://github.com/flyinghead/flycast/issues/1057) | 2023-05-06 | Soukou no Kihei Space Griffon | Japan | opening movie (real BIOS) | cutscene | standalone | no | [Soukou.no.Kihei.-.Space.Griffon_1.zip](https://github.com/flyinghead/flycast/files/11412361/Soukou.no.Kihei.-.Space.Griffon_1.zip) |
| [#1048](https://github.com/flyinghead/flycast/issues/1048) | 2023-04-30 | Trizeal | Japan | score attack messages | 2D shooter | RetroArch | no | [Trizeal.zip](https://github.com/flyinghead/flycast/files/11360949/Trizeal.zip) |
| [#1047](https://github.com/flyinghead/flycast/issues/1047) | 2023-04-29 | ECW Anarchy Rulz | ? | freezes on loading after the third title | avoid: freeze | standalone | no | [ECW.-.Anarchy.Rulz.zip](https://github.com/flyinghead/flycast/files/11358979/ECW.-.Anarchy.Rulz.zip) |
| [#1046](https://github.com/flyinghead/flycast/issues/1046) | 2023-04-29 | Kaen Seibo (disc 1) | Japan | disc swap | avoid: disc swap | RetroArch | no | [Kaen.Seibo.-.The.Virgin.on.Megiddo.Disc1.zip](https://github.com/flyinghead/flycast/files/11358946/Kaen.Seibo.-.The.Virgin.on.Megiddo.Disc1.zip) |
| [#1046](https://github.com/flyinghead/flycast/issues/1046) | 2024-01-27 | Dancing Blade 2 (disc 2) | Japan | disc swap, real BIOS | avoid: disc swap | RetroArch | no | [real_BIOS_Dancing.Blade.-.Katteni.Momo.Tenshi.II.Disc2.zip](https://github.com/flyinghead/flycast/files/14072729/real_BIOS_Dancing.Blade.-.Katteni.Momo.Tenshi.II.Disc2.zip) |
| [#1046](https://github.com/flyinghead/flycast/issues/1046) | 2024-01-27 | Dancing Blade 2 (disc 2) | Japan | disc swap, HLE BIOS | avoid: disc swap | RetroArch | no | [HLE_BIOS_Dancing.Blade.-.Katteni.Momo.Tenshi.II.Disc2.zip](https://github.com/flyinghead/flycast/files/14072730/HLE_BIOS_Dancing.Blade.-.Katteni.Momo.Tenshi.II.Disc2.zip) |
| [#1040](https://github.com/flyinghead/flycast/issues/1040) | 2023-04-27 | Izumo | Japan | 3D map, black floor | gameplay | standalone | no | [Izumo.zip](https://github.com/flyinghead/flycast/files/11343065/Izumo.zip) |
| [#1039](https://github.com/flyinghead/flycast/issues/1039) | 2023-04-27 | Golem no Maigo | Japan | stage select noise | menu | standalone | no | [Golem.no.Maigo.zip](https://github.com/flyinghead/flycast/files/11342882/Golem.no.Maigo.zip) |
| [#1038](https://github.com/flyinghead/flycast/issues/1038) | 2025-02-01 | World Series Baseball 2K2 | USA | scene with noise (freeze fixed) | gameplay | standalone | no | [World.Series.Baseball.2K2.v1.000.2001.Sega.US.1S.state.zip](https://github.com/user-attachments/files/18626862/World.Series.Baseball.2K2.v1.000.2001.Sega.US.1S.state.zip) |
| [#1033](https://github.com/flyinghead/flycast/issues/1033) | 2023-04-26 | L.O.L. - Lack of Love | Japan | analog stick | gameplay | standalone | yes | [L.O.L.-.Lack.of.Love.state.zip](https://github.com/flyinghead/flycast/files/11333438/L.O.L.-.Lack.of.Love.state.zip) |
| [#1030](https://github.com/flyinghead/flycast/issues/1030) | 2023-04-25 | Shenmue (disc 1) | ? | walking in a corridor, low sound | gameplay | RetroArch | Europe only | [Shenmue.Disc1.zip](https://github.com/flyinghead/flycast/files/11322678/Shenmue.Disc1.zip) |
| [#1030](https://github.com/flyinghead/flycast/issues/1030) | 2023-04-25 | Ready 2 Rumble Boxing | ? | referee count missing | fight | RetroArch | no | [Ready.2.Rumble.Boxing.zip](https://github.com/flyinghead/flycast/files/11322923/Ready.2.Rumble.Boxing.zip) |
| [#1029](https://github.com/flyinghead/flycast/issues/1029) | 2023-04-25 | Dogu Senki Haoh | Japan | loud noise | gameplay | standalone | no | [Dogu.Senki.-.Haoh.zip](https://github.com/flyinghead/flycast/files/11322223/Dogu.Senki.-.Haoh.zip) |
| [#1026](https://github.com/flyinghead/flycast/issues/1026) | 2023-04-24 | Urban Chaos | ? | buildings shadowed | gameplay | standalone | no | [Urban.Chaos.zip](https://github.com/flyinghead/flycast/files/11310005/Urban.Chaos.zip) |
| [#1025](https://github.com/flyinghead/flycast/issues/1025) | 2023-04-24 | Idol Janshi wo Tsukucchaou | Japan | graphics stretched | 2D | standalone | no | [Idol.Janshi.wo.Tsukucchaou.zip](https://github.com/flyinghead/flycast/files/11309773/Idol.Janshi.wo.Tsukucchaou.zip) |
| [#1021](https://github.com/flyinghead/flycast/issues/1021) | 2023-04-23 | Gaiamaster Kessen! Seikioh Densetsu | Japan | 3D dice characters uncoloured | gameplay | standalone | no | [Gaiamaster.-.Kessen.Seikioh.Densetsu.zip](https://github.com/flyinghead/flycast/files/11303498/Gaiamaster.-.Kessen.Seikioh.Densetsu.zip) |
| [#744](https://github.com/flyinghead/flycast/issues/744) | 2022-09-16 | Vampire Chronicles for Matching Service | Japan | fight | 2D fight | standalone | no | [save.state.zip](https://github.com/flyinghead/flycast/files/9590410/save.state.zip) |
| [#728](https://github.com/flyinghead/flycast/issues/728) | 2026-04-11 | South Park Rally | USA | sound effects cut off | racing | standalone | no | [South.Park.Rally.zip](https://github.com/user-attachments/files/26645551/South.Park.Rally.zip) |
| [#647](https://github.com/flyinghead/flycast/issues/647) | 2023-12-04 | Initial D Arcade Stage Ver. 3 (initdv3j) | Japan | hangs during boot | avoid: hang | standalone | no | [savestate.zip](https://github.com/flyinghead/flycast/files/13545330/savestate.zip) |
| [#327](https://github.com/flyinghead/flycast/issues/327) | 2021-08-24 | Grandia II | ? | DSP audio lag (Google Drive) | too old (2021) | RetroArch | yes | [Google Drive link](https://drive.google.com/file/d/1VmTzoppOHXzeRpeQOHT_ESkzR-aPJ-4S/view?usp=drivesdk) |
| [#188](https://github.com/flyinghead/flycast/issues/188) | 2021-02-25 | Legacy of Kain: Soul Reaver | ? | crash on meeting humans | too old (2021) | standalone | no | [legacy.zip](https://github.com/flyinghead/flycast/files/6044186/legacy.zip) |
| [#131](https://github.com/flyinghead/flycast/issues/131) | 2020-11-22 | Sakura Wars 2 | Japan | stuck before first battle | too old (2020) | standalone | no | [sakura_wars_2_stuck_battle_scene.gz](https://github.com/flyinghead/flycast/files/5579728/sakura_wars_2_stuck_battle_scene.gz) |
