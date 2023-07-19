// #pragma once
//
// #include "wlr-includes.hpp"
// #include <memory>
// #include "surfaces/zenith_surface.hpp"
//
//
// struct ZenithXWaylandSurface {
// 	ZenithXWaylandSurface(wlr_xwayland_surface* xwayland_surface);
//
// 	wlr_xwayland_surface* xwayland_surface;
// 	// std::shared_ptr<ZenithSurface> zenith_surface;
//
// 	/* callbacks */
// 	// wl_listener associateX11{};
// 	// wl_listener disociateX11{};
// 	wl_listener map{};
// 	wl_listener unmap{};
// 	wl_listener destroy{};
// };
//
// /*
//  * This event is raised when wlr_xdg_shell receives a new xdg surface from a
//  * client, either a toplevel (application window) or popup.
//  */
// void xwayland_surface_create(wl_listener* listener, void* data);
//
// void xwayland_ready_handle(wl_listener* listener, void* data);
