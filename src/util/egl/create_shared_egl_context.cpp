#include "create_shared_egl_context.hpp"

#include <cstring>
#include <iostream>


static const EGLint config_attribs[] = {
	  EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
	  EGL_RED_SIZE, 8,
	  EGL_GREEN_SIZE, 8,
	  EGL_BLUE_SIZE, 8,
	  EGL_ALPHA_SIZE, 8,
	  EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
	  EGL_NONE,
};

/// TODO: make some attribs conditional.
static const EGLint context_attribs[] = {
	  EGL_CONTEXT_CLIENT_VERSION, 2,
    EGL_CONTEXT_PRIORITY_LEVEL_IMG, EGL_CONTEXT_PRIORITY_HIGH_IMG,
    EGL_CONTEXT_OPENGL_RESET_NOTIFICATION_STRATEGY_EXT, EGL_LOSE_CONTEXT_ON_RESET_EXT,
	  EGL_NONE,
};


struct wlr_egl* create_shared_egl_context(struct wlr_egl* egl) {
	EGLConfig egl_config;

	EGLint matched = 0;
	if (!eglChooseConfig(wlr_egl_get_display(egl), config_attribs, &egl_config, 1, &matched)) {
		std::cerr << "eglChooseConfig failed" << std::endl;
		return nullptr;
	}
	if (matched == 0) {
		std::cerr << "Failed to match an EGL config" << std::endl;
		return nullptr;
	}

	// EGLContext shared_egl_context = eglCreateContext(wlr_egl_get_display(egl), egl_config, eglGetCurrentContext(), context_attribs);

  /// TODO: remove egl_config?
	EGLContext shared_egl_context = eglCreateContext(wlr_egl_get_display(egl), egl_config, wlr_egl_get_context(egl), context_attribs);
	if (shared_egl_context == EGL_NO_CONTEXT) {
		std::cerr << "Failed to create EGL context" << std::endl;
		return nullptr;
	}

  return wlr_egl_create_with_context(wlr_egl_get_display(egl), shared_egl_context);
}
