/*
 * vkprobe: Phase 0 Vulkan-under-Weston probe for the MLP1.
 *
 * Loads libvulkan.so.1 at runtime, prints instance/device capabilities, opens a
 * fullscreen xdg-shell window on the running compositor, creates a Vulkan
 * Wayland surface and (with --present N) presents N cleared frames through a
 * swapchain, reporting the frame interval.
 *
 * Usage: vkprobe [--present N] [--mode fifo|mailbox|immediate|relaxed]
 */
#define VK_NO_PROTOTYPES
#define VK_USE_PLATFORM_WAYLAND_KHR
#include <vulkan/vulkan.h>
#include <wayland-client.h>
#include "xdg-shell-client-protocol.h"

#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define CHECK(expr)                                                        \
    do {                                                                   \
        VkResult r_ = (expr);                                              \
        if (r_ != VK_SUCCESS) {                                            \
            fprintf(stderr, "FAIL %s -> %d (line %d)\n", #expr, r_, __LINE__); \
            exit(2);                                                       \
        }                                                                  \
    } while (0)

static PFN_vkGetInstanceProcAddr gipa;
#define IPROC(inst, name) PFN_##name name = (PFN_##name)gipa(inst, #name)

/* ---------------- Wayland ---------------- */
static struct wl_compositor *compositor;
static struct xdg_wm_base *wm_base;
static int cfg_w, cfg_h, configured;

static void output_geometry(void *d, struct wl_output *o, int32_t x, int32_t y,
                            int32_t pw, int32_t ph, int32_t sub, const char *make,
                            const char *model, int32_t transform)
{
    (void)d; (void)o; (void)sub;
    printf("wl_output geometry: pos %d,%d phys %dx%d mm make '%s' model '%s' transform %d\n",
           x, y, pw, ph, make, model, transform);
}
static void output_mode(void *d, struct wl_output *o, uint32_t flags, int32_t w,
                        int32_t h, int32_t refresh)
{
    (void)d; (void)o;
    printf("wl_output mode: %dx%d @ %.3f Hz flags 0x%x\n", w, h, refresh / 1000.0, flags);
}
static void output_done(void *d, struct wl_output *o) { (void)d; (void)o; }
static void output_scale(void *d, struct wl_output *o, int32_t s)
{
    (void)d; (void)o;
    printf("wl_output scale: %d\n", s);
}
static const struct wl_output_listener output_listener = {
    output_geometry, output_mode, output_done, output_scale, NULL, NULL,
};

static void wm_ping(void *d, struct xdg_wm_base *b, uint32_t serial)
{
    (void)d;
    xdg_wm_base_pong(b, serial);
}
static const struct xdg_wm_base_listener wm_listener = { wm_ping };

static void registry_global(void *d, struct wl_registry *reg, uint32_t name,
                            const char *iface, uint32_t version)
{
    (void)d;
    printf("wl_global: %s v%u\n", iface, version);
    if (!strcmp(iface, wl_compositor_interface.name))
        compositor = wl_registry_bind(reg, name, &wl_compositor_interface, 4);
    else if (!strcmp(iface, xdg_wm_base_interface.name)) {
        wm_base = wl_registry_bind(reg, name, &xdg_wm_base_interface, 1);
        xdg_wm_base_add_listener(wm_base, &wm_listener, NULL);
    } else if (!strcmp(iface, wl_output_interface.name)) {
        struct wl_output *o = wl_registry_bind(reg, name, &wl_output_interface,
                                               version < 2 ? version : 2);
        wl_output_add_listener(o, &output_listener, NULL);
    }
}
static void registry_remove(void *d, struct wl_registry *r, uint32_t n)
{
    (void)d; (void)r; (void)n;
}
static const struct wl_registry_listener registry_listener = { registry_global, registry_remove };

static void xs_configure(void *d, struct xdg_surface *s, uint32_t serial)
{
    (void)d;
    xdg_surface_ack_configure(s, serial);
    configured = 1;
}
static const struct xdg_surface_listener xs_listener = { xs_configure };

static void tl_configure(void *d, struct xdg_toplevel *t, int32_t w, int32_t h,
                         struct wl_array *states)
{
    (void)d; (void)t; (void)states;
    printf("xdg_toplevel configure: %dx%d\n", w, h);
    if (w > 0 && h > 0) {
        cfg_w = w;
        cfg_h = h;
    }
}
static void tl_close(void *d, struct xdg_toplevel *t) { (void)d; (void)t; }
static const struct xdg_toplevel_listener tl_listener = { tl_configure, tl_close, NULL, NULL };

static double now_ms(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1e6;
}

static const char *mode_name(VkPresentModeKHR m)
{
    switch (m) {
    case VK_PRESENT_MODE_IMMEDIATE_KHR: return "immediate";
    case VK_PRESENT_MODE_MAILBOX_KHR: return "mailbox";
    case VK_PRESENT_MODE_FIFO_KHR: return "fifo";
    case VK_PRESENT_MODE_FIFO_RELAXED_KHR: return "fifo_relaxed";
    default: return "other";
    }
}

int main(int argc, char **argv)
{
    int present_frames = 0;
    VkPresentModeKHR want_mode = VK_PRESENT_MODE_FIFO_KHR;
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--globals")) {
            /* List the compositor's globals only; no Vulkan. */
            struct wl_display *d = wl_display_connect(NULL);
            if (!d) {
                printf("RESULT verdict=no-wayland-display\n");
                return 5;
            }
            struct wl_registry *r = wl_display_get_registry(d);
            wl_registry_add_listener(r, &registry_listener, NULL);
            wl_display_roundtrip(d);
            wl_display_roundtrip(d);
            return 0;
        }
        if (!strcmp(argv[i], "--present") && i + 1 < argc)
            present_frames = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--mode") && i + 1 < argc) {
            const char *m = argv[++i];
            want_mode = !strcmp(m, "mailbox")     ? VK_PRESENT_MODE_MAILBOX_KHR
                        : !strcmp(m, "immediate") ? VK_PRESENT_MODE_IMMEDIATE_KHR
                        : !strcmp(m, "relaxed")   ? VK_PRESENT_MODE_FIFO_RELAXED_KHR
                                                  : VK_PRESENT_MODE_FIFO_KHR;
        }
    }

    void *lib = dlopen("libvulkan.so.1", RTLD_NOW | RTLD_LOCAL);
    if (!lib) {
        fprintf(stderr, "FAIL dlopen libvulkan.so.1: %s\n", dlerror());
        return 2;
    }
    gipa = (PFN_vkGetInstanceProcAddr)dlsym(lib, "vkGetInstanceProcAddr");

    IPROC(NULL, vkEnumerateInstanceExtensionProperties);
    IPROC(NULL, vkEnumerateInstanceLayerProperties);
    IPROC(NULL, vkCreateInstance);
    PFN_vkEnumerateInstanceVersion vkEnumerateInstanceVersion =
        (PFN_vkEnumerateInstanceVersion)gipa(NULL, "vkEnumerateInstanceVersion");

    uint32_t iver = VK_API_VERSION_1_0;
    if (vkEnumerateInstanceVersion)
        vkEnumerateInstanceVersion(&iver);
    printf("loader instance version: %u.%u.%u\n", VK_API_VERSION_MAJOR(iver),
           VK_API_VERSION_MINOR(iver), VK_API_VERSION_PATCH(iver));

    uint32_t n = 0;
    vkEnumerateInstanceLayerProperties(&n, NULL);
    VkLayerProperties *layers = calloc(n ? n : 1, sizeof(*layers));
    vkEnumerateInstanceLayerProperties(&n, layers);
    for (uint32_t i = 0; i < n; i++)
        printf("instance layer: %s (spec %u.%u, impl %u)\n", layers[i].layerName,
               VK_API_VERSION_MAJOR(layers[i].specVersion),
               VK_API_VERSION_MINOR(layers[i].specVersion), layers[i].implementationVersion);

    vkEnumerateInstanceExtensionProperties(NULL, &n, NULL);
    VkExtensionProperties *iexts = calloc(n ? n : 1, sizeof(*iexts));
    vkEnumerateInstanceExtensionProperties(NULL, &n, iexts);
    int have_wl = 0, have_surface = 0;
    for (uint32_t i = 0; i < n; i++) {
        printf("instance ext: %s\n", iexts[i].extensionName);
        if (!strcmp(iexts[i].extensionName, VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME)) have_wl = 1;
        if (!strcmp(iexts[i].extensionName, VK_KHR_SURFACE_EXTENSION_NAME)) have_surface = 1;
    }
    printf("RESULT wayland_surface_ext=%d\n", have_wl);

    const char *enable[2];
    uint32_t nenable = 0;
    if (have_surface) enable[nenable++] = VK_KHR_SURFACE_EXTENSION_NAME;
    if (have_wl) enable[nenable++] = VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME;

    VkApplicationInfo app = { .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
                              .pApplicationName = "vkprobe",
                              .apiVersion = iver >= VK_API_VERSION_1_1 ? VK_API_VERSION_1_1
                                                                       : VK_API_VERSION_1_0 };
    VkInstanceCreateInfo ici = { .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
                                 .pApplicationInfo = &app,
                                 .enabledExtensionCount = nenable,
                                 .ppEnabledExtensionNames = enable };
    VkInstance inst;
    CHECK(vkCreateInstance(&ici, NULL, &inst));

    IPROC(inst, vkEnumeratePhysicalDevices);
    IPROC(inst, vkGetPhysicalDeviceProperties);
    IPROC(inst, vkGetPhysicalDeviceMemoryProperties);
    IPROC(inst, vkGetPhysicalDeviceQueueFamilyProperties);
    IPROC(inst, vkEnumerateDeviceExtensionProperties);

    uint32_t ndev = 0;
    CHECK(vkEnumeratePhysicalDevices(inst, &ndev, NULL));
    if (!ndev) {
        printf("RESULT physical_devices=0\n");
        return 3;
    }
    VkPhysicalDevice *devs = calloc(ndev, sizeof(*devs));
    CHECK(vkEnumeratePhysicalDevices(inst, &ndev, devs));
    VkPhysicalDevice pd = devs[0];

    VkPhysicalDeviceProperties props;
    vkGetPhysicalDeviceProperties(pd, &props);
    printf("device: %s vendor 0x%x device 0x%x type %d\n", props.deviceName, props.vendorID,
           props.deviceID, props.deviceType);
    printf("RESULT device_api=%u.%u.%u driver_version=0x%x\n", VK_API_VERSION_MAJOR(props.apiVersion),
           VK_API_VERSION_MINOR(props.apiVersion), VK_API_VERSION_PATCH(props.apiVersion),
           props.driverVersion);
    printf("limits: maxImageDimension2D %u timestampPeriod %.3f maxPushConstantsSize %u\n",
           props.limits.maxImageDimension2D, props.limits.timestampPeriod,
           props.limits.maxPushConstantsSize);

    VkPhysicalDeviceMemoryProperties mp;
    vkGetPhysicalDeviceMemoryProperties(pd, &mp);
    int lazy = 0;
    for (uint32_t i = 0; i < mp.memoryHeapCount; i++)
        printf("heap %u: %llu MB flags 0x%x\n", i,
               (unsigned long long)(mp.memoryHeaps[i].size >> 20), mp.memoryHeaps[i].flags);
    for (uint32_t i = 0; i < mp.memoryTypeCount; i++) {
        printf("memtype %u: heap %u flags 0x%x\n", i, mp.memoryTypes[i].heapIndex,
               mp.memoryTypes[i].propertyFlags);
        if (mp.memoryTypes[i].propertyFlags & VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT) lazy = 1;
    }
    printf("RESULT lazily_allocated=%d\n", lazy);

    uint32_t nq = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(pd, &nq, NULL);
    VkQueueFamilyProperties *qf = calloc(nq, sizeof(*qf));
    vkGetPhysicalDeviceQueueFamilyProperties(pd, &nq, qf);
    for (uint32_t i = 0; i < nq; i++)
        printf("queue family %u: flags 0x%x count %u timestampValidBits %u\n", i, qf[i].queueFlags,
               qf[i].queueCount, qf[i].timestampValidBits);

    vkEnumerateDeviceExtensionProperties(pd, NULL, &n, NULL);
    VkExtensionProperties *dexts = calloc(n ? n : 1, sizeof(*dexts));
    vkEnumerateDeviceExtensionProperties(pd, NULL, &n, dexts);
    int have_swapchain = 0;
    for (uint32_t i = 0; i < n; i++) {
        printf("device ext: %s\n", dexts[i].extensionName);
        if (!strcmp(dexts[i].extensionName, VK_KHR_SWAPCHAIN_EXTENSION_NAME)) have_swapchain = 1;
    }
    printf("RESULT swapchain_ext=%d\n", have_swapchain);

    if (!have_wl) {
        printf("RESULT verdict=no-wayland-surface\n");
        return 4;
    }

    /* ---- Wayland window ---- */
    struct wl_display *dpy = wl_display_connect(NULL);
    if (!dpy) {
        printf("RESULT verdict=no-wayland-display\n");
        return 5;
    }
    struct wl_registry *reg = wl_display_get_registry(dpy);
    wl_registry_add_listener(reg, &registry_listener, NULL);
    wl_display_roundtrip(dpy);
    wl_display_roundtrip(dpy);
    if (!compositor || !wm_base) {
        printf("RESULT verdict=missing-compositor-or-xdg\n");
        return 5;
    }
    struct wl_surface *wsurf = wl_compositor_create_surface(compositor);
    struct xdg_surface *xs = xdg_wm_base_get_xdg_surface(wm_base, wsurf);
    xdg_surface_add_listener(xs, &xs_listener, NULL);
    struct xdg_toplevel *tl = xdg_surface_get_toplevel(xs);
    xdg_toplevel_add_listener(tl, &tl_listener, NULL);
    xdg_toplevel_set_title(tl, "vkprobe");
    xdg_toplevel_set_fullscreen(tl, NULL);
    wl_surface_commit(wsurf);
    while (!configured && wl_display_dispatch(dpy) != -1) {
    }

    IPROC(inst, vkCreateWaylandSurfaceKHR);
    IPROC(inst, vkGetPhysicalDeviceWaylandPresentationSupportKHR);
    IPROC(inst, vkGetPhysicalDeviceSurfaceCapabilitiesKHR);
    IPROC(inst, vkGetPhysicalDeviceSurfaceFormatsKHR);
    IPROC(inst, vkGetPhysicalDeviceSurfacePresentModesKHR);
    IPROC(inst, vkGetPhysicalDeviceSurfaceSupportKHR);

    printf("RESULT wayland_presentation_support=%u\n",
           vkGetPhysicalDeviceWaylandPresentationSupportKHR(pd, 0, dpy));

    VkWaylandSurfaceCreateInfoKHR wci = { .sType = VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR,
                                          .display = dpy,
                                          .surface = wsurf };
    VkSurfaceKHR surf;
    CHECK(vkCreateWaylandSurfaceKHR(inst, &wci, NULL, &surf));
    VkBool32 sup = 0;
    vkGetPhysicalDeviceSurfaceSupportKHR(pd, 0, surf, &sup);
    printf("RESULT surface_support_q0=%u\n", sup);

    VkSurfaceCapabilitiesKHR caps;
    CHECK(vkGetPhysicalDeviceSurfaceCapabilitiesKHR(pd, surf, &caps));
    printf("surface caps: images %u..%u currentExtent %ux%u min %ux%u max %ux%u currentTransform 0x%x "
           "supportedTransforms 0x%x compositeAlpha 0x%x usage 0x%x\n",
           caps.minImageCount, caps.maxImageCount, caps.currentExtent.width, caps.currentExtent.height,
           caps.minImageExtent.width, caps.minImageExtent.height, caps.maxImageExtent.width,
           caps.maxImageExtent.height, caps.currentTransform, caps.supportedTransforms,
           caps.supportedCompositeAlpha, caps.supportedUsageFlags);

    uint32_t nf = 0;
    vkGetPhysicalDeviceSurfaceFormatsKHR(pd, surf, &nf, NULL);
    VkSurfaceFormatKHR *fmts = calloc(nf ? nf : 1, sizeof(*fmts));
    vkGetPhysicalDeviceSurfaceFormatsKHR(pd, surf, &nf, fmts);
    for (uint32_t i = 0; i < nf; i++)
        printf("surface format: %d colorspace %d\n", fmts[i].format, fmts[i].colorSpace);

    uint32_t npm = 0;
    vkGetPhysicalDeviceSurfacePresentModesKHR(pd, surf, &npm, NULL);
    VkPresentModeKHR *pms = calloc(npm ? npm : 1, sizeof(*pms));
    vkGetPhysicalDeviceSurfacePresentModesKHR(pd, surf, &npm, pms);
    /* Prefer the 32-bit formats RetroArch picks over whatever comes first. */
    uint32_t pick = 0;
    for (uint32_t i = 0; i < nf; i++)
        if (fmts[i].format == VK_FORMAT_B8G8R8A8_UNORM) { pick = i; break; }
    if (fmts[pick].format != VK_FORMAT_B8G8R8A8_UNORM)
        for (uint32_t i = 0; i < nf; i++)
            if (fmts[i].format == VK_FORMAT_R8G8B8A8_UNORM) { pick = i; break; }
    fmts[0] = fmts[pick];
    int mode_ok = 0;
    for (uint32_t i = 0; i < npm; i++) {
        printf("present mode: %s\n", mode_name(pms[i]));
        if (pms[i] == want_mode) mode_ok = 1;
    }

    if (!present_frames) {
        printf("RESULT verdict=surface-ok\n");
        return 0;
    }
    if (!mode_ok) {
        printf("RESULT verdict=mode-unsupported %s\n", mode_name(want_mode));
        return 6;
    }

    /* ---- device + swapchain ---- */
    float prio = 1.0f;
    VkDeviceQueueCreateInfo qci = { .sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
                                    .queueFamilyIndex = 0,
                                    .queueCount = 1,
                                    .pQueuePriorities = &prio };
    const char *dext[] = { VK_KHR_SWAPCHAIN_EXTENSION_NAME };
    VkDeviceCreateInfo dci = { .sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
                               .queueCreateInfoCount = 1,
                               .pQueueCreateInfos = &qci,
                               .enabledExtensionCount = 1,
                               .ppEnabledExtensionNames = dext };
    IPROC(inst, vkCreateDevice);
    IPROC(inst, vkGetDeviceProcAddr);
    VkDevice dev;
    CHECK(vkCreateDevice(pd, &dci, NULL, &dev));
#define DPROC(name) PFN_##name name = (PFN_##name)vkGetDeviceProcAddr(dev, #name)
    DPROC(vkGetDeviceQueue);
    DPROC(vkCreateSwapchainKHR);
    DPROC(vkGetSwapchainImagesKHR);
    DPROC(vkAcquireNextImageKHR);
    DPROC(vkQueuePresentKHR);
    DPROC(vkQueueSubmit);
    DPROC(vkCreateCommandPool);
    DPROC(vkAllocateCommandBuffers);
    DPROC(vkBeginCommandBuffer);
    DPROC(vkEndCommandBuffer);
    DPROC(vkCmdPipelineBarrier);
    DPROC(vkCmdClearColorImage);
    DPROC(vkCreateSemaphore);
    DPROC(vkCreateFence);
    DPROC(vkWaitForFences);
    DPROC(vkResetFences);
    DPROC(vkResetCommandBuffer);
    DPROC(vkDeviceWaitIdle);

    VkQueue q;
    vkGetDeviceQueue(dev, 0, 0, &q);

    VkExtent2D ext = caps.currentExtent;
    if (ext.width == 0xFFFFFFFFu) {
        ext.width = cfg_w ? (uint32_t)cfg_w : 960;
        ext.height = cfg_h ? (uint32_t)cfg_h : 720;
    }
    uint32_t want_images = caps.minImageCount + 1;
    if (caps.maxImageCount && want_images > caps.maxImageCount) want_images = caps.maxImageCount;
    VkSwapchainCreateInfoKHR sci = {
        .sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
        .surface = surf,
        .minImageCount = want_images,
        .imageFormat = fmts[0].format,
        .imageColorSpace = fmts[0].colorSpace,
        .imageExtent = ext,
        .imageArrayLayers = 1,
        .imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT,
        .imageSharingMode = VK_SHARING_MODE_EXCLUSIVE,
        .preTransform = caps.currentTransform,
        .compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = want_mode,
        .clipped = VK_TRUE,
    };
    VkSwapchainKHR sc;
    CHECK(vkCreateSwapchainKHR(dev, &sci, NULL, &sc));
    uint32_t nimg = 0;
    vkGetSwapchainImagesKHR(dev, sc, &nimg, NULL);
    VkImage *imgs = calloc(nimg, sizeof(*imgs));
    vkGetSwapchainImagesKHR(dev, sc, &nimg, imgs);
    printf("swapchain: %u images %ux%u format %d mode %s\n", nimg, ext.width, ext.height,
           fmts[0].format, mode_name(want_mode));

    VkCommandPoolCreateInfo cpi = { .sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
                                    .flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
                                    .queueFamilyIndex = 0 };
    VkCommandPool pool;
    CHECK(vkCreateCommandPool(dev, &cpi, NULL, &pool));
    enum { FRAMES = 2 };
    VkCommandBuffer cbs[FRAMES];
    VkCommandBufferAllocateInfo cai = { .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
                                        .commandPool = pool,
                                        .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
                                        .commandBufferCount = FRAMES };
    CHECK(vkAllocateCommandBuffers(dev, &cai, cbs));
    VkSemaphore acq[FRAMES], done[FRAMES];
    VkFence fences[FRAMES];
    VkSemaphoreCreateInfo semi = { .sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
    VkFenceCreateInfo fi = { .sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
                             .flags = VK_FENCE_CREATE_SIGNALED_BIT };
    for (int i = 0; i < FRAMES; i++) {
        CHECK(vkCreateSemaphore(dev, &semi, NULL, &acq[i]));
        CHECK(vkCreateSemaphore(dev, &semi, NULL, &done[i]));
        CHECK(vkCreateFence(dev, &fi, NULL, &fences[i]));
    }

    double t0 = now_ms(), prev = t0, min_dt = 1e9, max_dt = 0;
    int slow = 0;
    for (int f = 0; f < present_frames; f++) {
        int s = f % FRAMES;
        CHECK(vkWaitForFences(dev, 1, &fences[s], VK_TRUE, UINT64_MAX));
        CHECK(vkResetFences(dev, 1, &fences[s]));
        uint32_t idx;
        VkResult ar = vkAcquireNextImageKHR(dev, sc, UINT64_MAX, acq[s], VK_NULL_HANDLE, &idx);
        if (ar != VK_SUCCESS && ar != VK_SUBOPTIMAL_KHR) {
            printf("RESULT verdict=acquire-failed %d at frame %d\n", ar, f);
            return 7;
        }
        VkCommandBuffer cb = cbs[s];
        vkResetCommandBuffer(cb, 0);
        VkCommandBufferBeginInfo bi = { .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
                                        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT };
        vkBeginCommandBuffer(cb, &bi);
        VkImageSubresourceRange rng = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
        VkImageMemoryBarrier b1 = { .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
                                    .srcAccessMask = 0,
                                    .dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT,
                                    .oldLayout = VK_IMAGE_LAYOUT_UNDEFINED,
                                    .newLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                                    .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
                                    .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
                                    .image = imgs[idx],
                                    .subresourceRange = rng };
        vkCmdPipelineBarrier(cb, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0,
                             0, NULL, 0, NULL, 1, &b1);
        /* Left half red-ish, cycling hue so stalls are visible on the panel. */
        float phase = (float)(f % 120) / 120.0f;
        VkClearColorValue col = { .float32 = { phase, 0.2f, 1.0f - phase, 1.0f } };
        vkCmdClearColorImage(cb, imgs[idx], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, &col, 1, &rng);
        VkImageMemoryBarrier b2 = b1;
        b2.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        b2.dstAccessMask = 0;
        b2.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        b2.newLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
        vkCmdPipelineBarrier(cb, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
                             0, 0, NULL, 0, NULL, 1, &b2);
        vkEndCommandBuffer(cb);
        VkPipelineStageFlags ws = VK_PIPELINE_STAGE_TRANSFER_BIT;
        VkSubmitInfo si = { .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO,
                            .waitSemaphoreCount = 1,
                            .pWaitSemaphores = &acq[s],
                            .pWaitDstStageMask = &ws,
                            .commandBufferCount = 1,
                            .pCommandBuffers = &cb,
                            .signalSemaphoreCount = 1,
                            .pSignalSemaphores = &done[s] };
        CHECK(vkQueueSubmit(q, 1, &si, fences[s]));
        VkPresentInfoKHR pi = { .sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
                                .waitSemaphoreCount = 1,
                                .pWaitSemaphores = &done[s],
                                .swapchainCount = 1,
                                .pSwapchains = &sc,
                                .pImageIndices = &idx };
        VkResult pr = vkQueuePresentKHR(q, &pi);
        if (pr != VK_SUCCESS && pr != VK_SUBOPTIMAL_KHR) {
            printf("RESULT verdict=present-failed %d at frame %d\n", pr, f);
            return 8;
        }
        wl_display_dispatch_pending(dpy);
        double t = now_ms(), dt = t - prev;
        prev = t;
        if (f >= 10) {
            if (dt < min_dt) min_dt = dt;
            if (dt > max_dt) max_dt = dt;
            if (dt > 20.0) slow++;
        }
    }
    vkDeviceWaitIdle(dev);
    double total = now_ms() - t0;
    printf("RESULT present_frames=%d avg_fps=%.2f min_dt_ms=%.2f max_dt_ms=%.2f over20ms=%d\n",
           present_frames, present_frames * 1000.0 / total, min_dt, max_dt, slow);
    printf("RESULT verdict=present-ok\n");
    return 0;
}
