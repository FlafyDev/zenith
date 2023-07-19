#pragma once
#include "wlr-includes.hpp"

#include "surfaces/zenith_xdg_surface.hpp"


// struct ZenithToplevelDecoration {
// 	wlr_xdg_toplevel_decoration_v1* wlr_toplevel_decoration;
// 	std::shared_ptr<ZenithXdgSurface> xdg_surface;
//
// 	wl_listener request_mode = {};
// 	wl_listener destroy = {};
//
// 	explicit ZenithToplevelDecoration(wlr_xdg_toplevel_decoration_v1* wlr_toplevel_decoration,
// 	                                  std::shared_ptr<ZenithXdgSurface> xdg_surface);
// };

void toplevel_decoration_create_handle(wl_listener* listener, void* data);

// void request_mode_handle(wl_listener* listener, void* data);
//
// void destroy_handle(wl_listener* listener, void* data);
