#pragma once

// TODO: Re-extract the functions when updating wlroots.

#include "../wlr-includes.hpp"
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES2/gl2.h>
#include <wayland-util.h>


// struct ZenithEGL {
// private:
// 	ZenithEGL();
//
// 	static ZenithEGL* _instance;
//
// public:
// 	static ZenithEGL* instance();
//
// 	struct {
// 		// Display extensions
// 		bool KHR_image_base;
// 		bool EXT_image_dma_buf_import;
// 		// bool EXT_image_dma_buf_import_modifiers;
// 		// bool IMG_context_priority;
// 		// bool EXT_create_context_robustness;
// 		//
// 		// // Device extensions
// 		// bool EXT_device_drm;
// 		// bool EXT_device_drm_render_node;
// 		//
// 		// // Client extensions
// 		// bool EXT_device_query;
// 		// bool KHR_platform_gbm;
// 		// bool EXT_platform_device;
// 		// bool KHR_display_reference;
// 	} exts;
//
// 	struct {
// 		// PFNEGLGETPLATFORMDISPLAYEXTPROC eglGetPlatformDisplayEXT;
// 		PFNEGLCREATEIMAGEKHRPROC eglCreateImageKHR;
// 		PFNEGLDESTROYIMAGEKHRPROC eglDestroyImageKHR;
// 		// PFNEGLQUERYDMABUFFORMATSEXTPROC eglQueryDmaBufFormatsEXT;
// 		// PFNEGLQUERYDMABUFMODIFIERSEXTPROC eglQueryDmaBufModifiersEXT;
// 		// PFNEGLDEBUGMESSAGECONTROLKHRPROC eglDebugMessageControlKHR;
// 		// PFNEGLQUERYDISPLAYATTRIBEXTPROC eglQueryDisplayAttribEXT;
// 		// PFNEGLQUERYDEVICESTRINGEXTPROC eglQueryDeviceStringEXT;
// 		// PFNEGLQUERYDEVICESEXTPROC eglQueryDevicesEXT;
// 	} procs;
// };
//
// struct wlr_drm_format* get_output_format(wlr_output* output);
//
// struct wlr_drm_format* output_pick_format(struct wlr_output* output,
//                                           const struct wlr_drm_format_set* display_formats,
//                                           uint32_t fmt);
//
// const struct wlr_drm_format_set* wlr_renderer_get_render_formats(
// 	  struct wlr_renderer* r);
//
// struct wlr_drm_format* wlr_drm_format_intersect(
// 	  const struct wlr_drm_format* a, const struct wlr_drm_format* b);
//
// struct wlr_drm_format* wlr_drm_format_dup(const struct wlr_drm_format* format);
//
bool wlr_egl_make_current(struct wlr_egl *egl);

bool wlr_egl_unset_current(struct wlr_egl *egl);
//
// bool wlr_egl_destroy_image(struct wlr_egl* egl, EGLImage image);
