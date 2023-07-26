#include "wlr_helpers.hpp"
#include <cassert>
#include <cstdio>
#include <GLES2/gl2ext.h>
#include <libdrm/drm_fourcc.h>

// ZenithEGL* ZenithEGL::_instance = nullptr;
//
// ZenithEGL* ZenithEGL::instance() {
// 	if (_instance == nullptr) {
// 		_instance = new ZenithEGL();
// 	}
// 	return _instance;
// }
//
// ZenithEGL::ZenithEGL() {
//
// }
//
// static void load_egl_proc(void *proc_ptr, const char *name) {
// 	void *proc = (void *)eglGetProcAddress(name);
// 	if (proc == NULL) {
// 		wlr_log(WLR_ERROR, "eglGetProcAddress(%s) failed", name);
// 		abort();
// 	}
// 	*(void **)proc_ptr = proc;
// }
//
// struct wlr_drm_format* get_output_format(wlr_output* output) {
// 	struct wlr_allocator* allocator = output->allocator;
// 	assert(allocator != nullptr);
//
// 	const struct wlr_drm_format_set* display_formats =
// 		  wlr_output_get_primary_formats(output, allocator->buffer_caps);
// 	struct wlr_drm_format* format = output_pick_format(output, display_formats,
// 	                                                   output->render_format);
// 	if (format == nullptr) {
// 		wlr_log(WLR_ERROR, "Failed to pick primary buffer format for output '%s'",
// 		        output->name);
// 		return nullptr;
// 	}
// 	return format;
// }
//
bool wlr_egl_make_current(struct wlr_egl *egl) {
	if (!eglMakeCurrent(wlr_egl_get_display(egl), EGL_NO_SURFACE, EGL_NO_SURFACE, wlr_egl_get_context(egl))) {
		wlr_log(WLR_ERROR, "eglMakeCurrent failed");
		return false;
	}
	return true;
}

bool wlr_egl_unset_current(struct wlr_egl *egl) {
	if (!eglMakeCurrent(wlr_egl_get_display(egl), EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT)) {
		wlr_log(WLR_ERROR, "eglMakeCurrent failed");
		return false;
	}
	return true;
}
//
// struct wlr_drm_format*
// output_pick_format(struct wlr_output* output, const struct wlr_drm_format_set* display_formats, uint32_t fmt) {
// 	struct wlr_renderer* renderer = output->renderer;
// 	struct wlr_allocator* allocator = output->allocator;
// 	assert(renderer != nullptr && allocator != nullptr);
//
// 	const struct wlr_drm_format_set* render_formats =
// 		  wlr_renderer_get_render_formats(renderer);
// 	if (render_formats == nullptr) {
// 		wlr_log(WLR_ERROR, "Failed to get render formats");
// 		return nullptr;
// 	}
//
// 	const struct wlr_drm_format* render_format =
// 		  wlr_drm_format_set_get(render_formats, fmt);
// 	if (render_format == nullptr) {
// 		wlr_log(WLR_DEBUG, "Renderer doesn't support format 0x%" PRIX32, fmt);
// 		return nullptr;
// 	}
//
// 	struct wlr_drm_format* format = nullptr;
// 	if (display_formats != nullptr) {
// 		const struct wlr_drm_format* display_format =
// 			  wlr_drm_format_set_get(display_formats, fmt);
// 		if (display_format == nullptr) {
// 			wlr_log(WLR_DEBUG, "Output doesn't support format 0x%" PRIX32, fmt);
// 			return nullptr;
// 		}
// 		format = wlr_drm_format_intersect(display_format, render_format);
// 	} else {
// 		// The output can display any format
// 		format = wlr_drm_format_dup(render_format);
// 	}
//
// 	if (format == nullptr) {
// 		wlr_log(WLR_DEBUG, "Failed to intersect display and render "
// 		                   "modifiers for format 0x%" PRIX32 " on output '%s",
// 		        fmt, output->name);
// 		return nullptr;
// 	}
//
// 	return format;
// }
//
// const struct wlr_drm_format_set* wlr_renderer_get_render_formats(struct wlr_renderer* r) {
// 	if (!r->impl->get_render_formats) {
// 		return nullptr;
// 	}
// 	return r->impl->get_render_formats(r);
// }
//
// struct wlr_drm_format* wlr_drm_format_intersect(const struct wlr_drm_format* a, const struct wlr_drm_format* b) {
// 	assert(a->format == b->format);
//
// 	size_t format_cap = a->len < b->len ? a->len : b->len;
// 	size_t format_size = sizeof(struct wlr_drm_format) +
// 	                     format_cap * sizeof(a->modifiers[0]);
// 	auto* format = static_cast<wlr_drm_format*>(calloc(1, format_size));
// 	if (format == nullptr) {
// 		wlr_log_errno(WLR_ERROR, "Allocation failed");
// 		return nullptr;
// 	}
// 	format->format = a->format;
// 	format->capacity = format_cap;
//
// 	for (size_t i = 0; i < a->len; i++) {
// 		for (size_t j = 0; j < b->len; j++) {
// 			if (a->modifiers[i] == b->modifiers[j]) {
// 				assert(format->len < format->capacity);
// 				format->modifiers[format->len] = a->modifiers[i];
// 				format->len++;
// 				break;
// 			}
// 		}
// 	}
//
// 	// If the intersection is empty, then the formats aren't compatible with
// 	// each other.
// 	if (format->len == 0) {
// 		free(format);
// 		return nullptr;
// 	}
//
// 	return format;
// }
//
// struct wlr_drm_format* wlr_drm_format_dup(const struct wlr_drm_format* format) {
// 	assert(format->len <= format->capacity);
// 	size_t format_size = sizeof(struct wlr_drm_format) +
// 	                     format->capacity * sizeof(format->modifiers[0]);
// 	auto* duped_format = static_cast<wlr_drm_format*>(malloc(format_size));
// 	if (duped_format == nullptr) {
// 		return nullptr;
// 	}
// 	memcpy(duped_format, format, format_size);
// 	return duped_format;
// }
//
// void push_gles2_debug_(struct wlr_gles2_renderer* renderer,
//                        const char* file, const char* func) {
// 	if (!renderer->procs.glPushDebugGroupKHR) {
// 		return;
// 	}
//
// 	int len = snprintf(NULL, 0, "%s:%s", file, func) + 1;
// 	char str[len];
// 	snprintf(str, len, "%s:%s", file, func);
// 	renderer->procs.glPushDebugGroupKHR(GL_DEBUG_SOURCE_APPLICATION_KHR, 1, -1, str);
// }
//
// #define push_gles2_debug(renderer) push_gles2_debug_(renderer, _WLR_FILENAME, __func__)
//
// void pop_gles2_debug(struct wlr_gles2_renderer* renderer) {
// 	if (renderer->procs.glPopDebugGroupKHR) {
// 		renderer->procs.glPopDebugGroupKHR();
// 	}
// }
//
// void wlr_egl_save_context(struct wlr_egl_context* context) {
// 	context->display = eglGetCurrentDisplay();
// 	context->context = eglGetCurrentContext();
// 	context->draw_surface = eglGetCurrentSurface(EGL_DRAW);
// 	context->read_surface = eglGetCurrentSurface(EGL_READ);
// }
//
// bool wlr_egl_restore_context(struct wlr_egl_context* context) {
// 	// If the saved context is a null-context, we must use the current
// 	// display instead of the saved display because eglMakeCurrent() can't
// 	// handle EGL_NO_DISPLAY.
// 	EGLDisplay display = context->display == EGL_NO_DISPLAY ?
// 	                     eglGetCurrentDisplay() : context->display;
//
// 	// If the current display is also EGL_NO_DISPLAY, we assume that there
// 	// is currently no context set and no action needs to be taken to unset
// 	// the context.
// 	if (display == EGL_NO_DISPLAY) {
// 		return true;
// 	}
//
// 	return eglMakeCurrent(display, context->draw_surface,
// 	                      context->read_surface, context->context);
//   // wlr_allocator_create_buffer()
// }
//
//
// // static void handle_buffer_destroy(struct wlr_addon* addon) {
// // 	struct wlr_gles2_buffer* buffer =
// // 		  wl_container_of(addon, buffer, addon);
// // 	destroy_buffer(buffer);
// // }
// //
// // static const struct wlr_addon_interface buffer_addon_impl = {
// // 	  .name = "wlr_gles2_buffer",
// // 	  .destroy = handle_buffer_destroy,
// // };
//
// bool wlr_egl_destroy_image(struct wlr_egl* egl, EGLImage image) {
// 	if (!ZenithEGL::instance()->exts.KHR_image_base) {
// 		return false;
// 	}
// 	if (!image) {
// 		return true;
// 	}
//   return ZenithEGL::instance()->procs.eglDestroyImageKHR(wlr_egl_get_display(egl), image);
// }
//
