#pragma once

#include "../wlr-includes.hpp"
#include "zenith_xdg_surface.hpp"


struct ZenithXdgPopup {
	ZenithXdgPopup(wlr_xdg_popup* xdg_popup, std::shared_ptr<ZenithXdgSurface> zenith_xdg_surface);

	wlr_xdg_popup* xdg_popup;
	std::shared_ptr<ZenithXdgSurface> zenith_xdg_surface;
};
