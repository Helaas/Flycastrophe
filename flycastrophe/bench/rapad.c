/*
 * rapad — drive RetroArch's built-in network gamepad on the MLP1.
 *
 * RetroArch compiled with HAVE_NETWORKGAMEPAD binds a UDP socket on
 * network_remote_base_port + user (default 55400 for user 1) and applies every
 * well-formed packet it receives in its input poll. Two consequences matter:
 *
 *   * There is no device enumeration, so unlike a uinput clone (uipad) the pad
 *     does not have to exist before RetroArch starts, and there is no SDL
 *     joypad index to guess. That index is exactly what made the uipad route
 *     fragile on this device, which exposes three identically named
 *     "Loong Gamepad" devices.
 *   * RetroArch ORs network input with the real pad (input_state_device
 *     checks INPUT_REMOTE_KEY_PRESSED first), so the physical controls keep
 *     working during a benchmark run.
 *
 * Packet layout, from input_driver.h:
 *
 *   struct remote_message { int port, device, index, id; uint16_t state; };
 *
 * sizeof() is 20 on aarch64 (16 bytes of int + uint16 + 2 bytes tail padding).
 * recvfrom only accepts an exact-size datagram, and a short read clears every
 * button, so the full 20 bytes must be sent. input_remote_parse_packet ignores
 * msg.port. Device 1 (JOYPAD) sets bit `id` (RETRO_DEVICE_ID_JOYPAD_*); device
 * 5 (ANALOG) sets stick axis analog[index*2+id] for index 0/1 only.
 *
 *   rapad <port> [--hold MS] [--gap MS] TOKEN [TOKEN ...]
 *
 * TOKEN is one control or a chord of controls joined by '+', held together
 * (e.g. RT+LEFT). Names are DREAMCAST buttons, translated through Flycast's
 * positional RetroPad mapping (RetroPad B = DC A, RetroPad A = DC B,
 * RetroPad Y = DC X, RetroPad X = DC Y):
 *
 *   A B X Y START UP DOWN LEFT RIGHT LT RT
 *   SL SR SU SD          left analog stick pushed fully left/right/up/down
 *   RP_<name>            raw RetroPad id, e.g. RP_A, RP_L, RP_SELECT
 *
 * Analog triggers: RetroArch's ANALOG_BUTTON query ignores the network pad,
 * so LT/RT arrive as the digital L2/R2 bits. Flycast falls back to the digital
 * bit when the analog trigger reads zero, giving a full-press trigger.
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>

#define RETRO_DEVICE_JOYPAD 1
#define RETRO_DEVICE_ANALOG 5
#define MAX_CHORD 8

struct remote_message {
    int port;
    int device;
    int index;
    int id;
    uint16_t state;
};

struct control { int device, id; int16_t value; };

static const struct { const char *name; struct control c; } controls[] = {
    /* Dreamcast names (Flycast positional mapping) */
    { "A",      { RETRO_DEVICE_JOYPAD, 0,  1 } },  /* RetroPad B */
    { "B",      { RETRO_DEVICE_JOYPAD, 8,  1 } },  /* RetroPad A */
    { "X",      { RETRO_DEVICE_JOYPAD, 1,  1 } },  /* RetroPad Y */
    { "Y",      { RETRO_DEVICE_JOYPAD, 9,  1 } },  /* RetroPad X */
    { "START",  { RETRO_DEVICE_JOYPAD, 3,  1 } },
    { "UP",     { RETRO_DEVICE_JOYPAD, 4,  1 } },
    { "DOWN",   { RETRO_DEVICE_JOYPAD, 5,  1 } },
    { "LEFT",   { RETRO_DEVICE_JOYPAD, 6,  1 } },
    { "RIGHT",  { RETRO_DEVICE_JOYPAD, 7,  1 } },
    { "LT",     { RETRO_DEVICE_JOYPAD, 12, 1 } },  /* RetroPad L2 */
    { "RT",     { RETRO_DEVICE_JOYPAD, 13, 1 } },  /* RetroPad R2 */
    { "SL",     { RETRO_DEVICE_ANALOG, 0, -32767 } },
    { "SR",     { RETRO_DEVICE_ANALOG, 0,  32767 } },
    { "SU",     { RETRO_DEVICE_ANALOG, 1, -32767 } },
    { "SD",     { RETRO_DEVICE_ANALOG, 1,  32767 } },
    /* raw RetroPad ids */
    { "RP_B", { 1, 0, 1 } }, { "RP_Y", { 1, 1, 1 } }, { "RP_SELECT", { 1, 2, 1 } },
    { "RP_START", { 1, 3, 1 } }, { "RP_UP", { 1, 4, 1 } }, { "RP_DOWN", { 1, 5, 1 } },
    { "RP_LEFT", { 1, 6, 1 } }, { "RP_RIGHT", { 1, 7, 1 } }, { "RP_A", { 1, 8, 1 } },
    { "RP_X", { 1, 9, 1 } }, { "RP_L", { 1, 10, 1 } }, { "RP_R", { 1, 11, 1 } },
    { "RP_L2", { 1, 12, 1 } }, { "RP_R2", { 1, 13, 1 } }, { "RP_L3", { 1, 14, 1 } },
    { "RP_R3", { 1, 15, 1 } },
};

static int fd;
static struct sockaddr_in dst;
static int port = 55400;

static void msleep(int ms)
{
    struct timespec ts = { ms / 1000, (long)(ms % 1000) * 1000000L };
    nanosleep(&ts, NULL);
}

static int send_control(const struct control *c, int pressed)
{
    struct remote_message msg;
    memset(&msg, 0, sizeof(msg));
    msg.port   = port;
    msg.device = c->device;
    msg.index  = 0;
    msg.id     = c->id;
    msg.state  = pressed ? (uint16_t)c->value : 0;
    return sendto(fd, &msg, sizeof(msg), 0, (struct sockaddr *)&dst, sizeof(dst)) == (ssize_t)sizeof(msg);
}

static int parse_chord(char *token, struct control *out)
{
    int n = 0;
    char *save = NULL, *name;
    for (name = strtok_r(token, "+", &save); name; name = strtok_r(NULL, "+", &save)) {
        int k, found = 0;
        if (n == MAX_CHORD) { fprintf(stderr, "rapad: chord too long\n"); return -1; }
        for (k = 0; k < (int)(sizeof(controls) / sizeof(controls[0])); k++)
            if (!strcmp(name, controls[k].name)) { out[n++] = controls[k].c; found = 1; break; }
        if (!found) { fprintf(stderr, "rapad: unknown control %s\n", name); return -1; }
    }
    return n;
}

int main(int argc, char **argv)
{
    int hold = 120, gap = 200;
    int i, first = 1;

    if (argc < 3) {
        fprintf(stderr, "usage: %s <port> [--hold MS] [--gap MS] TOKEN...\n", argv[0]);
        return 2;
    }
    port = atoi(argv[1]);

    fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) { perror("socket"); return 1; }
    memset(&dst, 0, sizeof(dst));
    dst.sin_family = AF_INET;
    dst.sin_port   = htons((uint16_t)port);
    dst.sin_addr.s_addr = htonl(INADDR_LOOPBACK);

    for (i = 2; i < argc; i++) {
        struct control chord[MAX_CHORD];
        int n, k;

        if (!strcmp(argv[i], "--hold") && i + 1 < argc) { hold = atoi(argv[++i]); continue; }
        if (!strcmp(argv[i], "--gap")  && i + 1 < argc) { gap  = atoi(argv[++i]); continue; }

        if ((n = parse_chord(argv[i], chord)) <= 0) return 2;
        if (!first) msleep(gap);
        first = 0;
        /*
         * RetroArch's remote poll does exactly one recvfrom per user per
         * frame. A single press packet followed shortly by a release can
         * both be queued and consumed before the core ever samples the
         * button, which made presses intermittently disappear. Re-sending
         * the press through the hold keeps it set across many frames; the
         * release then lands cleanly. A chord round-robins one packet per
         * 20 ms tick, so the queue never grows faster than RA drains it.
         */
        {
            int waited = 0, tick = 0;
            for (k = 0; k < n; k++)
                if (!send_control(&chord[k], 1)) { perror("send press"); return 1; }
            while (waited < hold) {
                msleep(20);
                waited += 20;
                if (!send_control(&chord[tick++ % n], 1)) { perror("send press"); return 1; }
            }
        }
        for (k = 0; k < n; k++)
            if (!send_control(&chord[k], 0)) { perror("send release"); return 1; }
    }
    msleep(gap);
    return 0;
}
