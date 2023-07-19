// #include "xwayland.hpp"
// #include <platform_channels/binary_messenger.hpp>
// #include "server.hpp"
// #include "util/assert.hpp"
//
//
// void xwayland_ready_handle(wl_listener* listener, void* data) {
// 	ZenithServer* server = wl_container_of(listener, server, xwayland_new_surface);
//   // wlr_log(WLR_ERROR, "Could not create Wayland display1");
//  //  server->xwayland->seat = nullptr;
// 	// wlr_xwayland_set_seat(server->xwayland, server->seat);
//   // wlr_log(WLR_ERROR, "Could not create Wayland display2");
// }
//
// void xwayland_surface_create(wl_listener* listener, void* data) {
// 	ZenithServer* server = wl_container_of(listener, server, xwayland_new_surface);
// 	auto* xwayland_surface = static_cast<wlr_xwayland_surface*>(data);
//
//   wlr_log(WLR_ERROR, "Pointer value: %p", xwayland_surface->surface);
//
// 	auto* zenith_xwayland_surface = new ZenithXWaylandSurface(xwayland_surface);
// 	xwayland_surface->data = zenith_xwayland_surface;
// 	auto zenith_xwayland_surface_ref = std::shared_ptr<ZenithXWaylandSurface>(zenith_xwayland_surface);
// 	server->xwayland_surfaces.insert(std::make_pair(xwayland_surface->surface_id, zenith_xwayland_surface_ref));
// }
//
// void zenith_xwayland_surface_map(wl_listener* listener, void* data) {
// 	// ZenithXWaylandSurface* zenith_xwayland_surface = wl_container_of(listener, zenith_xwayland_surface, map);
// 	auto* xwayland_surface = static_cast<wlr_xwayland_surface*>(data);
//   wlr_log(WLR_ERROR, "Pointer value0.5: %p", xwayland_surface);
// 	auto zenith_xwayland_surface = static_cast<ZenithXWaylandSurface*>(xwayland_surface->data);
//   wlr_log(WLR_ERROR, "Pointer value1: %i", xwayland_surface->surface_id);
//   wlr_log(WLR_ERROR, "Pointer value1.5: %p", xwayland_surface->surface);
//   if (xwayland_surface->surface_id == 0) return;
//   // if (xwayland_surface->surface_id) {
//   //   return;
//   // }
// 	size_t id = zenith_xwayland_surface->xwayland_surface->surface_id;
// 	ZenithServer::instance()->embedder_state->map_xwayland_surface(id);
// }
//
// void zenith_xwayland_surface_unmap(wl_listener* listener, void* data) {
// 	auto* xwayland_surface = static_cast<wlr_xwayland_surface*>(data);
//   wlr_log(WLR_ERROR, "Pointer value0.5: %p", xwayland_surface);
// 	auto zenith_xwayland_surface = static_cast<ZenithXWaylandSurface*>(xwayland_surface->data);
//   wlr_log(WLR_ERROR, "Pointer value1: %i", xwayland_surface->surface_id);
//   wlr_log(WLR_ERROR, "Pointer value1.5: %p", xwayland_surface->surface);
//   if (xwayland_surface->surface_id == 0) return;
// 	size_t id = zenith_xwayland_surface->xwayland_surface->surface_id;
// 	ZenithServer::instance()->embedder_state->unmap_xwayland_surface(id);
// }
//
// void zenith_xwayland_surface_destroy(wl_listener* listener, void* data) {
// 	auto* xwayland_surface = static_cast<wlr_xwayland_surface*>(data);
//   wlr_log(WLR_ERROR, "Pointer value0.5: %p", xwayland_surface);
// 	auto zenith_xwayland_surface = static_cast<ZenithXWaylandSurface*>(xwayland_surface->data);
//   wlr_log(WLR_ERROR, "Pointer value1: %i", xwayland_surface->surface_id);
//   wlr_log(WLR_ERROR, "Pointer value1.5: %p", xwayland_surface->surface);
//   if (xwayland_surface->surface_id == 0) return;
// 	size_t id = zenith_xwayland_surface->xwayland_surface->surface_id;
//
// // ZenithXdgSurface* zenith_xdg_surface = wl_container_of(listener, zenith_xdg_surface, destroy);
// 	auto* server = ZenithServer::instance();
//
// 	bool erased = server->xwayland_surfaces.erase(id);
// 	// assert(erased);
// }
//
// ZenithXWaylandSurface::ZenithXWaylandSurface(wlr_xwayland_surface* xwayland_surface)
// 	  : xwayland_surface{xwayland_surface} {
// 	destroy.notify = zenith_xwayland_surface_destroy;
// 	wl_signal_add(&xwayland_surface->events.destroy, &destroy);
//
// 	// map.notify = zenith_xwayland_surface_map;
// 	// wl_signal_add(&xwayland_surface->events.associate, &map);
// 	//
// 	// unmap.notify = zenith_xwayland_surface_unmap;
// 	// wl_signal_add(&xwayland_surface->events.unmap, &unmap);
//
// 	// map.notify = zenith_xwayland_surface_map;
// 	// wl_signal_add(&xwayland_surface->events.map, &map);
// 	//
// 	// unmap.notify = zenith_xwayland_surface_unmap;
// 	// wl_signal_add(&xwayland_surface->events.unmap, &unmap);
// }
// //
// // void zenith_xdg_surface_create(wl_listener* listener, void* data) {
// // 	ZenithServer* server = wl_container_of(listener, server, new_xdg_surface);
// // 	auto* xdg_surface = static_cast<wlr_xdg_surface*>(data);
// // 	auto* zenith_surface = static_cast<ZenithSurface*>(xdg_surface->surface->data);
// // 	const std::shared_ptr<ZenithSurface>& zenith_surface_ref = server->surfaces.at(zenith_surface->id);
// //
// // 	auto* zenith_xdg_surface = new ZenithXdgSurface(xdg_surface, zenith_surface_ref);
// // 	xdg_surface->data = zenith_xdg_surface;
// // 	auto zenith_xdg_surface_ref = std::shared_ptr<ZenithXdgSurface>(zenith_xdg_surface);
// // 	server->xdg_surfaces.insert(std::make_pair(zenith_surface->id, zenith_xdg_surface_ref));
// //
// // 	switch (xdg_surface->role) {
// // 		case WLR_XDG_SURFACE_ROLE_NONE:
// // 			ASSERT(false, "unreachable");
// // 			break;
// // 		case WLR_XDG_SURFACE_ROLE_TOPLEVEL: {
// // 			wlr_xdg_toplevel_set_maximized(xdg_surface, true);
// // 			auto toplevel = new ZenithXdgToplevel(xdg_surface->toplevel, zenith_xdg_surface_ref);
// // 			server->xdg_toplevels.insert(std::make_pair(zenith_surface->id, toplevel));
// // 			break;
// // 		}
// // 		case WLR_XDG_SURFACE_ROLE_POPUP:
// // 			auto popup = new ZenithXdgPopup(xdg_surface->popup, zenith_xdg_surface_ref);
// // 			server->xdg_popups.insert(std::make_pair(zenith_surface->id, popup));
// // 			break;
// // 	}
// // }
// //
// // void zenith_xdg_surface_map(wl_listener* listener, void* data) {
// // 	ZenithXdgSurface* zenith_xdg_surface = wl_container_of(listener, zenith_xdg_surface, map);
// // 	size_t id = zenith_xdg_surface->zenith_surface->id;
// // 	ZenithServer::instance()->embedder_state->map_xdg_surface(id);
// // }
// //
// // void zenith_xdg_surface_unmap(wl_listener* listener, void* data) {
// // 	ZenithXdgSurface* zenith_xdg_surface = wl_container_of(listener, zenith_xdg_surface, unmap);
// // 	size_t id = zenith_xdg_surface->zenith_surface->id;
// // 	ZenithServer::instance()->embedder_state->unmap_xdg_surface(id);
// // }
// //
// // void zenith_xdg_surface_destroy(wl_listener* listener, void* data) {
// // 	auto* xdg_surface = static_cast<wlr_xdg_surface*>(data);
// // 	auto zenith_xdg_surface = static_cast<ZenithXdgSurface*>(xdg_surface->data);
// // 	size_t id = zenith_xdg_surface->zenith_surface->id;
// //
// // //	ZenithXdgSurface* zenith_xdg_surface = wl_container_of(listener, zenith_xdg_surface, destroy);
// // 	auto* server = ZenithServer::instance();
// //
// // 	if (zenith_xdg_surface->xdg_surface->role == WLR_XDG_SURFACE_ROLE_TOPLEVEL) {
// // 		bool erased = server->xdg_toplevels.erase(id);
// // 		assert(erased);
// // 	} else if (zenith_xdg_surface->xdg_surface->role == WLR_XDG_SURFACE_ROLE_POPUP) {
// // 		bool erased = server->xdg_popups.erase(id);
// // 		assert(erased);
// // 	}
// // 	bool erased = server->xdg_surfaces.erase(id);
// // 	assert(erased);
// // }
