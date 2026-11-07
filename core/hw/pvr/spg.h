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
