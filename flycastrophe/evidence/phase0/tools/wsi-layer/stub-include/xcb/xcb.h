/* Build-only stub: the WSI layer's private_data.hpp includes <xcb/xcb.h> even when
 * the X11 backend is off, only so <vulkan/vulkan_xcb.h> has its handle types.
 * The MLP1 sysroot has no libxcb. Nothing here is called. */
#ifndef FLYCASTROPHE_STUB_XCB_H
#define FLYCASTROPHE_STUB_XCB_H
#include <stdint.h>
typedef struct xcb_connection_t xcb_connection_t;
typedef uint32_t xcb_window_t;
typedef uint32_t xcb_visualid_t;
#endif
