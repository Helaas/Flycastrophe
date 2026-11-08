#pragma once
#include "ta_ctx.h"

extern bool SH4FastEnough;
// Deadcast: how far emulation is behind real time (ms): what the auto frame skip goes by (ta_ctx.cpp)
extern float emulationLagMs;

bool spg_Init();
void spg_Term();
void spg_Reset(bool Manual);
void spg_Serialize(Serializer& ser);
void spg_Deserialize(Deserializer& deser);

void CalculateSync();
void read_lightgun_position(int x, int y);
void scheduleRenderDone(TA_context *cntx);
void rescheduleSPG();
// Deadcast perf (row 01): with FLYCASTROPHE_PERF=1 a line every second in the log: emulated vblanks, renders,
// the threads' CPU, the SH4's waits for the renderer, texture updates, compiles. Off, each hook is one test.
bool perfOn();
// now, for perfWaited/perfRendered (0 when off)
unsigned long long perfNow();
// the emulation thread waited for the renderer, from start (perfNow()) until now
void perfWaited(unsigned long long start);
// a render done (renderer thread), from start
void perfRendered(unsigned long long start, bool toTexture);
// a texture decoded and uploaded again (size: its bytes in VRAM)
void perfTextureUpdated(u32 size);
// of those, data a texture there had before (in the last 10 s), not at its last upload
void perfTextureRecurring();
// the AICA thread's: its CPU clock, for its share of a core
void perfAicaThread();
