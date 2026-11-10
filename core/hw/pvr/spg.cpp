#include "spg.h"
#include "hw/holly/holly_intc.h"
#include "hw/holly/sb.h"
#include "hw/sh4/sh4_sched.h"
#include "hw/maple/maple_if.h"
#include "serialize.h"
#include "network/ggpo.h"
#include "hw/pvr/Renderer_if.h"
extern u32 bmStatCodeWrites, bmStatCodeDropped, bmStatCodeStores;
#include "stdclass.h"
#include <algorithm>
#include <array>
#include <chrono>
#include <atomic>
#include <cstdlib>
#include <pthread.h>
#include <time.h>
#include "deadcast/waitloops.h"
#include "hw/sh4/modules/mmu.h"

#ifdef TEST_AUTOMATION
#include "input/gamepad_device.h"
#endif

//SPG emulation; Scanline/Raster beam registers & interrupts

// Deadcast perf (spg.h), the part that applies under RetroArch (no presenter, GPU timers or audio backend
// of its own). FLYCASTROPHE_PERF=1 turns it on.
static const bool perfEnabled = [] { const char *e = std::getenv("FLYCASTROPHE_PERF"); return e != nullptr && *e != '\0' && *e != '0'; }();
static std::atomic<u64> perfWaitUs, perfRenderUs, perfRenderMaxUs;
static std::atomic<u32> perfRenders, perfTextureRenders, perfTextureUpdates, perfTextureBytes, perfTextureAgain;
static std::atomic<u32> perfGlDraws, perfGlPrograms, perfGlTextures;
static std::atomic<bool> perfRenderClockSet, perfAicaClockSet;
static clockid_t perfRenderClock, perfAicaClock;
extern u32 bmStatCompiled, bmStatCacheResets;
extern u64 bmStatCompileUs;
extern float emulationLagMs;

static u64 perfNowUs()
{
	return std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
}

static u64 perfCpuUs(clockid_t clock)
{
	timespec ts;
	clock_gettime(clock, &ts);
	return (u64)ts.tv_sec * 1000000 + ts.tv_nsec / 1000;
}

bool perfOn() {
	return perfEnabled;
}

bool perfFrameHash() {
	static const bool on = [] { const char *e = std::getenv("FLYCASTROPHE_GLHASH"); return perfEnabled && e != nullptr && *e == '1'; }();
	return on;
}

unsigned long long perfNow() {
	return perfEnabled ? perfNowUs() : 0;
}

void perfWaited(unsigned long long start)
{
	if (perfEnabled)
		perfWaitUs.fetch_add(perfNowUs() - start, std::memory_order_relaxed);
}

void perfRendered(unsigned long long start, bool toTexture)
{
	if (!perfEnabled)
		return;
	if (!perfRenderClockSet.load(std::memory_order_acquire))
	{
		pthread_getcpuclockid(pthread_self(), &perfRenderClock);
		perfRenderClockSet.store(true, std::memory_order_release);
	}
	if (toTexture)
		perfTextureRenders.fetch_add(1, std::memory_order_relaxed);
	const u64 took = perfNowUs() - start;
	perfRenderUs.fetch_add(took, std::memory_order_relaxed);
	u64 max = perfRenderMaxUs.load(std::memory_order_relaxed);
	while (took > max && !perfRenderMaxUs.compare_exchange_weak(max, took, std::memory_order_relaxed))
		;
	perfRenders.fetch_add(1, std::memory_order_relaxed);
}

void perfTextureUpdated(u32 size)
{
	if (!perfEnabled)
		return;
	perfTextureUpdates.fetch_add(1, std::memory_order_relaxed);
	perfTextureBytes.fetch_add(size, std::memory_order_relaxed);
}

void perfTextureRecurring()
{
	if (perfEnabled)
		perfTextureAgain.fetch_add(1, std::memory_order_relaxed);
}

void perfGlWork(u32 draws, u32 programs, u32 textures)
{
	if (!perfEnabled)
		return;
	perfGlDraws.fetch_add(draws, std::memory_order_relaxed);
	perfGlPrograms.fetch_add(programs, std::memory_order_relaxed);
	perfGlTextures.fetch_add(textures, std::memory_order_relaxed);
}

void perfAicaThread()
{
	if (!perfEnabled)
		return;
	pthread_getcpuclockid(pthread_self(), &perfAicaClock);
	perfAicaClockSet.store(true, std::memory_order_release);
}

static u32 Frame_Cycles;

// each emulated vblank (SH4 thread): a line every second of real time
static void perfVblank()
{
	static u64 start, windowStart, emuCpu, renderCpu, aicaCpu, lastVblank, frameMaxUs;
	static u32 vblanks, frames, skipped, framesOver;
	extern u32 fskip;
	const u64 now = perfNowUs();
	if (lastVblank != 0)
	{
		// the wall time between two emulated vblanks: over 17.5 ms (a frame is 16.68), that frame was late
		const u64 frame = now - lastVblank;
		frameMaxUs = std::max(frameMaxUs, frame);
		if (frame > 17500)
			framesOver++;
	}
	lastVblank = now;
	const bool renderClock = perfRenderClockSet.load(std::memory_order_acquire);
	const bool aicaClock = perfAicaClockSet.load(std::memory_order_acquire);
	if (start == 0)
	{
		start = windowStart = now;
		frames = FrameCount;
		skipped = fskip;
		perfWaitUs = 0;
		emuCpu = perfCpuUs(CLOCK_THREAD_CPUTIME_ID);
		renderCpu = renderClock ? perfCpuUs(perfRenderClock) : 0;
		aicaCpu = aicaClock ? perfCpuUs(perfAicaClock) : 0;
		return;
	}
	vblanks++;
	if (now - windowStart < 1000000)
		return;
	const double secs = (now - windowStart) / 1e6;
	const double window = (double)(now - windowStart);
	const double nominal = (double)SH4_MAIN_CLOCK / Frame_Cycles;
	const u64 emuNow = perfCpuUs(CLOCK_THREAD_CPUTIME_ID);
	const u64 renderNow = renderClock ? perfCpuUs(perfRenderClock) : 0;
	const u64 aicaNow = aicaClock ? perfCpuUs(perfAicaClock) : 0;
	const u32 renders = perfRenders.exchange(0);
	const u64 renderUs = perfRenderUs.exchange(0);
	NOTICE_LOG(COMMON, "Flycastrophe perf %6.1f s: vblank %5.2f/s %5.1f%% lag %4.1f ms | rendered %5.2f/s skipped %5.2f/s"
			" | emu cpu %3.0f%% waits %3.0f%% | render cpu %3.0f%% | aica cpu %3.0f%%"
			" | renders %u (to textures %u) %.1f ms max %.1f | textures updated %u (%u KB, seen before %u)"
			" | compiled %u in %.1f ms resets %u | wait turns skipped %u asleep %.1f%% | mmu flushes %u+%u misses %u"
			" | emu frames late %u max %.1f ms | gl per render: draws %.0f programs %.0f textures %.0f"
			" | code writes %u stores %u dropped %u",
			(now - start) / 1e6, vblanks / secs, vblanks / secs / nominal * 100.0, emulationLagMs,
			(FrameCount - frames) / secs, (fskip - skipped) / secs,
			(emuNow - emuCpu) / window * 100.0, perfWaitUs.exchange(0) / window * 100.0,
			renderCpu != 0 ? (renderNow - renderCpu) / window * 100.0 : 0.0,
			aicaCpu != 0 ? (aicaNow - aicaCpu) / window * 100.0 : 0.0,
			renders, perfTextureRenders.exchange(0), renders ? renderUs / 1000.0 / renders : 0.0, perfRenderMaxUs.exchange(0) / 1000.0,
			perfTextureUpdates.exchange(0), perfTextureBytes.exchange(0) / 1024, perfTextureAgain.exchange(0),
			bmStatCompiled, bmStatCompileUs / 1000.0, bmStatCacheResets,
			deadcast::waitLoopTurnsSkipped,
			deadcast::sleepTimeslices * (double)SH4_TIMESLICE / ((double)vblanks * Frame_Cycles) * 100.0,
			mmuStatFullFlushes, mmuStatPartialFlushes, mmuStatMisses,
			framesOver, frameMaxUs / 1000.0,
			perfGlDraws.exchange(0) / std::max(1.0, (double)renders),
			perfGlPrograms.exchange(0) / std::max(1.0, (double)renders),
			perfGlTextures.exchange(0) / std::max(1.0, (double)renders),
			bmStatCodeWrites, bmStatCodeStores, bmStatCodeDropped);
	bmStatCodeWrites = bmStatCodeDropped = bmStatCodeStores = 0;
	windowStart = now;
	vblanks = 0;
	frames = FrameCount;
	skipped = fskip;
	emuCpu = emuNow;
	renderCpu = renderNow;
	aicaCpu = aicaNow;
	framesOver = 0;
	frameMaxUs = 0;
	bmStatCompiled = bmStatCacheResets = 0;
	bmStatCompileUs = 0;
	deadcast::waitLoopTurnsSkipped = 0;
	deadcast::sleepTimeslices = 0;
	mmuStatFullFlushes = mmuStatPartialFlushes = mmuStatMisses = 0;
}

static u32 clc_pvr_scanline;
static u32 pvr_numscanlines = 512;
static u32 prv_cur_scanline = -1;

#if !defined(NDEBUG) || defined(DEBUGFAST)
static u32 vblk_cnt;
static u64 last_fps;
#endif

// 27 mhz pixel clock
constexpr int PIXEL_CLOCK = 27 * 1000 * 1000;
static u32 Line_Cycles;
int render_end_schid;
int vblank_schid;

static std::array<double, 4> real_times;
static std::array<u64, 4> cpu_cycles;
static u32 cpu_time_idx;
bool SH4FastEnough;
u32 fskip;
float emulationLagMs;

static u32 lightgun_line = 0xffff;
static u32 lightgun_hpos;
static bool maple_int_pending;

#ifdef LIBRETRO
extern void retro_setfps(double fps);
#endif

void CalculateSync()
{
	u32 pixel_clock = PIXEL_CLOCK / (FB_R_CTRL.vclk_div ? 1 : 2);

	// We need to calculate the pixel clock

	pvr_numscanlines = SPG_LOAD.vcount + 1;

	Line_Cycles = (u32)((u64)SH4_MAIN_CLOCK * (u64)(SPG_LOAD.hcount + 1) / (u64)pixel_clock);
	if (SPG_CONTROL.interlace)
		Line_Cycles /= 2;

	Frame_Cycles = pvr_numscanlines * Line_Cycles;
	prv_cur_scanline = 0;
	clc_pvr_scanline = 0;

	sh4_sched_request(vblank_schid, Line_Cycles);

#ifdef LIBRETRO
	retro_setfps((double)SH4_MAIN_CLOCK / ((double)Line_Cycles * (double)pvr_numscanlines));
#endif
}

static int getNextSpgInterrupt()
{
	if (SPG_HBLANK_INT.hblank_int_mode == 2)
		return Line_Cycles;

	u32 min_scanline = prv_cur_scanline + 1;
	u32 min_active = pvr_numscanlines;

	if (min_scanline <= SPG_VBLANK_INT.vblank_in_interrupt_line_number)
		min_active = std::min(min_active, SPG_VBLANK_INT.vblank_in_interrupt_line_number);

	if (min_scanline <= SPG_VBLANK_INT.vblank_out_interrupt_line_number)
		min_active = std::min(min_active, SPG_VBLANK_INT.vblank_out_interrupt_line_number);

	if (min_scanline <= SPG_VBLANK.vstart)
		min_active = std::min(min_active, SPG_VBLANK.vstart);

	if (min_scanline <= SPG_VBLANK.vbend)
		min_active = std::min(min_active, SPG_VBLANK.vbend);

	if (lightgun_line != 0xffff && min_scanline <= lightgun_line)
		min_active = std::min(min_active, lightgun_line);

	if (SPG_HBLANK_INT.hblank_int_mode == 0 && min_scanline <= SPG_HBLANK_INT.line_comp_val)
		min_active = std::min(min_active, SPG_HBLANK_INT.line_comp_val);

	min_active = std::max(min_active, min_scanline);

	return (min_active - prv_cur_scanline) * Line_Cycles;
}

void rescheduleSPG()
{
	sh4_sched_request(vblank_schid, getNextSpgInterrupt());
}

static int spg_line_sched(int tag, int cycles, int jitter, void *arg)
{
	clc_pvr_scanline += cycles + jitter;

	while (clc_pvr_scanline >= Line_Cycles)
	{
		prv_cur_scanline = (prv_cur_scanline + 1) % pvr_numscanlines;
		clc_pvr_scanline -= Line_Cycles;
		
		if (SPG_VBLANK_INT.vblank_in_interrupt_line_number == prv_cur_scanline)
		{
			if (maple_int_pending)
			{
				maple_int_pending = false;
				SB_MDST = 0;
			}
			asic_RaiseInterrupt(holly_SCANINT1);
		}

		if (SPG_VBLANK_INT.vblank_out_interrupt_line_number == prv_cur_scanline)
		{
			maple_vblank();
			asic_RaiseInterrupt(holly_SCANINT2);
		}

		if (SPG_VBLANK.vstart == prv_cur_scanline)
			SPG_STATUS.vsync = 1;

		if (SPG_VBLANK.vbend == prv_cur_scanline)
			SPG_STATUS.vsync = 0;

		SPG_STATUS.scanline = prv_cur_scanline;
		
		switch (SPG_HBLANK_INT.hblank_int_mode)
		{
		case 0:
			if (prv_cur_scanline == SPG_HBLANK_INT.line_comp_val)
				asic_RaiseInterrupt(holly_HBLank);
			break;
		case 2:
			asic_RaiseInterrupt(holly_HBLank);
			break;
		case 1:
			WARN_LOG(PVR, "Unimplemented HBLANK INT mode");
			break;
		default:
			INFO_LOG(PVR, "Invalid HBLANK INT mode");
			break;
		}

		// Vblank
		if (prv_cur_scanline == 0)
		{
			if (SPG_CONTROL.interlace)
				SPG_STATUS.fieldnum = ~SPG_STATUS.fieldnum;
			else
				SPG_STATUS.fieldnum = 0;

			rend_vblank();
			if (perfEnabled)
				perfVblank();

			u64 now = getTimeMs();
			cpu_time_idx = (cpu_time_idx + 1) % cpu_cycles.size();
			if (cpu_cycles[cpu_time_idx] != 0)
			{
				u32 cycle_span = (u32)(sh4_sched_now64() - cpu_cycles[cpu_time_idx]);
				u64 time_span = now - real_times[cpu_time_idx];
				float cpu_speed = ((float)cycle_span / time_span) / (SH4_MAIN_CLOCK / 100000);
				SH4FastEnough = cpu_speed >= 85.f;
			}
			else {
				SH4FastEnough = false;
			}
			cpu_cycles[cpu_time_idx] = sh4_sched_now64();
			real_times[cpu_time_idx] = now;

			// Deadcast: the lag is real time since the last vblank minus emulated time, summed and capped at
			// 50 ms (a load or pause is not lag to make up). Flycastrophe: down to -50 ms too, since RetroArch
			// paces the SH4 in bursts (a frame ahead, then a wait for it); floored at 0, the waits alone
			// added up to lag and skipped half the frames of a game at full speed.
			// Flycastrophe: and no more than a frame of each interval counts. RetroArch runs the SH4 at real
			// time, so a stall (a level's first load compiling its code and shaders, 0.2 s and more) can't
			// be won back by running ahead: counted in full, Crazy Taxi's first level load held the lag at
			// the cap and the skip dropped up to 2 frames in 3 for 10 s. A burst's wait (a frame) still
			// counts in full, and so does steady slowness, a few ms every frame.
			{
				static std::chrono::steady_clock::time_point lastReal;
				static u64 lastCycles;
				const auto real = std::chrono::steady_clock::now();
				const u64 cycles = sh4_sched_now64();
				if (lastCycles != 0 && cycles > lastCycles)
				{
					const float realMs = std::chrono::duration<float, std::milli>(real - lastReal).count();
					const float sh4Ms = (float)(cycles - lastCycles) / (SH4_MAIN_CLOCK / 1000);
					const float late = std::min(realMs - sh4Ms, sh4Ms);
					emulationLagMs = std::clamp(emulationLagMs + late, -50.f, 50.f);
					// Flycastrophe: and lag fades, 2% a vblank. Deadcast's own loop works lag off by running
					// ahead; under RetroArch audio sync holds the SH4 to real time, so lag left over the
					// threshold stayed there and the skip with it (a third of the runs at 1.1 GHz showed
					// 34 fps for 40 s, the others 60). Steady slowness of more than 1% still climbs over it.
					if (emulationLagMs > 0.f)
						emulationLagMs *= 0.98f;
				}
				else
					emulationLagMs = 0.f;
				lastReal = real;
				lastCycles = cycles;
			}

#ifdef TEST_AUTOMATION
			replay_input();
#endif

#if !defined(NDEBUG) || defined(DEBUGFAST)
			vblk_cnt++;
			if (getTimeMs() - last_fps >= 2000)
			{
				static int Last_FC;
				double ts = ((double)getTimeMs() - last_fps) / 1000.0;
				double spd_fps = (FrameCount - Last_FC) / ts;
				double spd_vbs = vblk_cnt / ts;
				double spd_cpu = spd_vbs * Frame_Cycles;
				spd_cpu /= 1000000.0;	//mrhz kthx
				double fullvbs = (spd_vbs / spd_cpu) * 200.0;

				Last_FC=FrameCount;

				vblk_cnt=0;

				const char* mode=0;
				const char* res=0;

				res = SPG_CONTROL.interlace ? "480i" : "240p";

				if (SPG_CONTROL.isPAL())
					mode = "PAL";
				else if (SPG_CONTROL.isNTSC())
					mode = "NTSC";
				else
				{
					res = SPG_CONTROL.interlace ? "480i" : "480p";
					mode = "VGA";
				}

				double frames_done=spd_cpu/2;
				double mspdf=1/frames_done*1000;

				double full_rps = spd_fps + fskip / ts;

				INFO_LOG(COMMON, "SPG - %4.2f - %4.2f - V: %4.2f (%.2f, %s%s%4.2f) R: %4.2f+%4.2f",
					mspdf, spd_cpu * 100 / 200, spd_vbs,
					spd_vbs / full_rps, mode, res, fullvbs,
					spd_fps, fskip / ts);
				
				fskip = 0;
				last_fps = getTimeMs();
			}
#endif
		}
		if (lightgun_line != 0xffff && lightgun_line == prv_cur_scanline)
		{
			maple_int_pending = false;
			SPG_TRIGGER_POS = ((lightgun_line & 0x3FF) << 16) | (lightgun_hpos & 0x3FF);
			SB_MDST = 0;
			lightgun_line = 0xffff;
		}
	}

	return getNextSpgInterrupt();
}

void read_lightgun_position(int x, int y)
{
	static u32 flip;
	maple_int_pending = true;
	if (y < 0 || y >= 480 || x < 0 || x >= 640)
	{
		// Off screen
		lightgun_line = 0xffff;
	}
	else
	{
		lightgun_line = y / (SPG_CONTROL.interlace ? 2 : 1) + SPG_VBLANK_INT.vblank_out_interrupt_line_number;
		// For some reason returning the same position twice makes it register off screen.
		// Atomiswave Clay Challenge wants more wiggle than others for shots to register.
		lightgun_line ^= (flip >> 1) & 1;
		lightgun_hpos = (x + 286) ^ (flip & 1);
		flip++;
	}
}

bool spg_Init()
{
	render_end_schid = sh4_sched_register(0, &rend_end_render);
	vblank_schid = sh4_sched_register(0, &spg_line_sched);

	return true;
}

void spg_Term()
{
	sh4_sched_unregister(render_end_schid);
	render_end_schid = -1;
	sh4_sched_unregister(vblank_schid);
	vblank_schid = -1;
}

void spg_Reset(bool hard)
{
	CalculateSync();

	SH4FastEnough = false;
	cpu_time_idx = 0;
	cpu_cycles.fill(0);
	real_times.fill(0.0);
	maple_int_pending = false;
	lightgun_line = 0xffff;
	lightgun_hpos = 0;
}

void scheduleRenderDone(TA_context *cntx)
{
	int cycles = 4096;
	if (cntx != nullptr)
	{
		if (settings.platform.isNaomi2()) {
			cycles = 1500000;
		}
		else
		{
			int size = 0;
			for (TA_context *c = cntx; c != nullptr; c = c->nextContext)
				size += c->tad.thd_data - c->tad.thd_root;
			cycles = std::min(450000 + size * 100, 1500000);
		}
	}
	sh4_sched_request(render_end_schid, cycles);
}

void spg_Serialize(Serializer& ser)
{
	ser << clc_pvr_scanline;
	ser << maple_int_pending;
	ser << pvr_numscanlines;
	ser << prv_cur_scanline;
	ser << Line_Cycles;
	ser << Frame_Cycles;
	ser << lightgun_line;
	ser << lightgun_hpos;
}
void spg_Deserialize(Deserializer& deser)
{
	if (deser.version() < Deserializer::V30)
		deser.skip<u32>(); // in_vblank
	deser >> clc_pvr_scanline;
	deser >> maple_int_pending;
	deser >> pvr_numscanlines;
	deser >> prv_cur_scanline;
	deser >> Line_Cycles;
	deser >> Frame_Cycles;
	deser >> lightgun_line;
	deser >> lightgun_hpos;
}
