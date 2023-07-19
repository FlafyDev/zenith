#pragma once

#include "../wlr-includes.hpp"
#include "zenith_xdg_surface.hpp"


struct ZenithXdgToplevel {
	ZenithXdgToplevel(wlr_xdg_toplevel* xdg_toplevel,
	                  std::shared_ptr<ZenithXdgSurface> zenith_xdg_surface);

	wlr_xdg_toplevel* xdg_toplevel;
	std::shared_ptr<ZenithXdgSurface> zenith_xdg_surface;
	bool visible = true;

	/* callbacks */
	wl_listener request_move = {};
	wl_listener request_resize = {};
	wl_listener set_app_id = {};
	wl_listener set_title = {};

	void focus() const;

	void maximize(bool value) const;

	void resize(size_t width, size_t height) const;
};

void zenith_xdg_toplevel_set_app_id(wl_listener* listener, void* data);

void zenith_xdg_toplevel_set_title(wl_listener* listener, void* data);

void zenith_xdg_toplevel_request_move(wl_listener* listener, void* data);

void zenith_xdg_toplevel_request_resize(wl_listener* listener, void* data);
