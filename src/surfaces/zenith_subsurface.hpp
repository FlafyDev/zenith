#pragma once
#include "../wlr-includes.hpp"

#include <memory>
#include "zenith_surface.hpp"



struct ZenithSubsurface {
	explicit ZenithSubsurface(wlr_subsurface* subsurface, std::shared_ptr<ZenithSurface> zenith_surface);

	wlr_subsurface* subsurface;
	std::shared_ptr<ZenithSurface> zenith_surface;

	wl_listener map{};
	wl_listener unmap{};
	wl_listener destroy{};
};

void zenith_subsurface_create(wl_listener* listener, void* data);

void zenith_subsurface_map(wl_listener* listener, void* data);

void zenith_subsurface_unmap(wl_listener* listener, void* data);

void zenith_subsurface_destroy(wl_listener* listener, void* data);
