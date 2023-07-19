#pragma once

#include "../wlr-includes.hpp"
#include <memory>
#include "zenith_surface.hpp"



struct ZenithXdgSurface {
	ZenithXdgSurface(wlr_xdg_surface* xdg_surface, std::shared_ptr<ZenithSurface> zenith_surface);

	wlr_xdg_surface* xdg_surface;
	std::shared_ptr<ZenithSurface> zenith_surface;

	/* callbacks */
	wl_listener map{};
	wl_listener unmap{};
	wl_listener destroy{};
};

/*
 * This event is raised when wlr_xdg_shell receives a new xdg surface from a
 * client, either a toplevel (application window) or popup.
 */
void zenith_xdg_surface_create(wl_listener* listener, void* data);

void zenith_xdg_surface_map(wl_listener* listener, void* data);

void zenith_xdg_surface_unmap(wl_listener* listener, void* data);

void zenith_xdg_surface_destroy(wl_listener* listener, void* data);
