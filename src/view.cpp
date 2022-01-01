#include "view.hpp"
#include "server.hpp"
#include "platform_channels/encodable_value.h"
#include "standard_method_codec.h"

extern "C" {
#define static
#include <wlr/render/wlr_texture.h>
#include <wlr/types/wlr_xdg_shell.h>
#include <wlr/render/gles2.h>
#undef static
}

using namespace flutter;

static size_t next_view_id = 1;

ZenithView::ZenithView(ZenithServer* server, wlr_xdg_surface* xdg_surface)
	  : server(server), xdg_surface(xdg_surface), id(next_view_id++) {

	/* Listen to the various events it can emit */
	map.notify = xdg_surface_map;
	wl_signal_add(&xdg_surface->events.map, &map);

	unmap.notify = xdg_surface_unmap;
	wl_signal_add(&xdg_surface->events.unmap, &unmap);

	destroy.notify = xdg_surface_destroy;
	wl_signal_add(&xdg_surface->events.destroy, &destroy);

	commit.notify = surface_commit;
	wl_signal_add(&xdg_surface->surface->events.commit, &commit);

	if (xdg_surface->role == WLR_XDG_SURFACE_ROLE_TOPLEVEL) {
		request_move.notify = xdg_toplevel_request_move;
		wl_signal_add(&xdg_surface->toplevel->events.request_move, &request_move);

		request_resize.notify = xdg_toplevel_request_resize;
		wl_signal_add(&xdg_surface->toplevel->events.request_resize, &request_resize);
	}
}

void ZenithView::focus() {
	if (xdg_surface->role != WLR_XDG_SURFACE_ROLE_TOPLEVEL) {
		// Popups cannot get focus.
		return;
	}

	wlr_seat* seat = server->seat;
	wlr_keyboard* keyboard = wlr_seat_get_keyboard(seat);

	wlr_surface* prev_surface = seat->keyboard_state.focused_surface;

	bool is_surface_already_focused = prev_surface == xdg_surface->surface;
	if (is_surface_already_focused) {
		return;
	}

	if (prev_surface != nullptr) {
		/*
		 * Deactivate the previously focused surface. This lets the client know
		 * it no longer has focus and the client will repaint accordingly, e.g.
		 * stop displaying a caret.
		 */
		// TODO segfault, see segfault1.txt
		wlr_xdg_surface* previous = wlr_xdg_surface_from_wlr_surface(seat->keyboard_state.focused_surface);
		wlr_xdg_toplevel_set_activated(previous, false);
	}
	// Activate the new surface.
	wlr_xdg_toplevel_set_activated(xdg_surface, true);
	/*
	 * Tell the seat to have the keyboard enter this surface. wlroots will keep
	 * track of this and automatically send key events to the appropriate
	 * clients without additional work on your part.
	 */
	wlr_seat_keyboard_notify_enter(seat, xdg_surface->surface,
	                               keyboard->keycodes, keyboard->num_keycodes, &keyboard->modifiers);
}

void xdg_surface_map(wl_listener* listener, void* data) {
	ZenithView* view = wl_container_of(listener, view, map);
	view->mapped = true;
	view->focus();

	wlr_xdg_surface* xdg_surface = view->xdg_surface;
	wlr_surface* surface = xdg_surface->surface;
	wlr_texture* texture = wlr_surface_get_texture(surface);
	assert(texture != nullptr);

	FlutterEngineRegisterExternalTexture(view->server->output->flutter_engine_state->engine, (int64_t) view->id);

	switch (view->xdg_surface->role) {
		case WLR_XDG_SURFACE_ROLE_TOPLEVEL: {
			auto value = EncodableValue(EncodableMap{
				  {EncodableValue("view_id"),        EncodableValue((int64_t) view->id)},
				  {EncodableValue("surface_width"),  EncodableValue(surface->current.width)},
				  {EncodableValue("surface_height"), EncodableValue(surface->current.height)},
				  {EncodableValue("visible_bounds"), EncodableValue(EncodableMap{
						{EncodableValue("x"),      EncodableValue(xdg_surface->geometry.x)},
						{EncodableValue("y"),      EncodableValue(xdg_surface->geometry.y)},
						{EncodableValue("width"),  EncodableValue(xdg_surface->geometry.width)},
						{EncodableValue("height"), EncodableValue(xdg_surface->geometry.height)},
				  })},
			});
			auto result = StandardMethodCodec::GetInstance().EncodeSuccessEnvelope(&value);

			view->server->output->flutter_engine_state->messenger.Send("window_mapped", result->data(), result->size());
			break;
		}
		case WLR_XDG_SURFACE_ROLE_POPUP: {
			wlr_xdg_popup* popup = view->xdg_surface->popup;
			wlr_xdg_surface* parent_xdg_surface = wlr_xdg_surface_from_wlr_surface(popup->parent);
			wlr_box parent_geometry = parent_xdg_surface->geometry;
			size_t parent_view_id = view->server->view_id_by_wlr_surface[parent_xdg_surface->surface];

			auto value = EncodableValue(EncodableMap{
				  {EncodableValue("view_id"),        EncodableValue((int64_t) view->id)},
				  {EncodableValue("parent_view_id"), EncodableValue((int64_t) parent_view_id)},
				  {EncodableValue("x"),              EncodableValue(parent_geometry.x + popup->geometry.x)},
				  {EncodableValue("y"),              EncodableValue(parent_geometry.y + popup->geometry.y)},
				  {EncodableValue("surface_width"),  EncodableValue(view->xdg_surface->surface->current.width)},
				  {EncodableValue("surface_height"), EncodableValue(view->xdg_surface->surface->current.height)},
				  {EncodableValue("visible_bounds"), EncodableValue(EncodableMap{
						{EncodableValue("x"),      EncodableValue(popup->base->geometry.x)},
						{EncodableValue("y"),      EncodableValue(popup->base->geometry.y)},
						{EncodableValue("width"),  EncodableValue(popup->base->geometry.width)},
						{EncodableValue("height"), EncodableValue(popup->base->geometry.height)},
				  })},
			});
			auto result = StandardMethodCodec::GetInstance().EncodeSuccessEnvelope(&value);

			view->server->output->flutter_engine_state->messenger.Send("popup_mapped", result->data(), result->size());
			break;
		}
		case WLR_XDG_SURFACE_ROLE_NONE:
			break;
	}
}

void xdg_surface_unmap(wl_listener* listener, void* data) {
	ZenithView* view = wl_container_of(listener, view, unmap);
	view->mapped = false;

	switch (view->xdg_surface->role) {
		case WLR_XDG_SURFACE_ROLE_TOPLEVEL: {
			auto value = EncodableValue(EncodableMap{
				  {EncodableValue("view_id"), EncodableValue((int64_t) view->id)},
			});
			auto result = StandardMethodCodec::GetInstance().EncodeSuccessEnvelope(&value);

			view->server->output->flutter_engine_state->messenger.Send("window_unmapped", result->data(),
			                                                           result->size());
			break;
		}
		case WLR_XDG_SURFACE_ROLE_POPUP: {
			wlr_xdg_popup* popup = view->xdg_surface->popup;

			auto value = EncodableValue(EncodableMap{
				  {EncodableValue("view_id"),            EncodableValue((int64_t) view->id)},
				  {EncodableValue("parent_surface_ptr"), EncodableValue((int64_t) popup->parent)},
			});
			auto result = StandardMethodCodec::GetInstance().EncodeSuccessEnvelope(&value);

			view->server->output->flutter_engine_state->messenger.Send("popup_unmapped", result->data(),
			                                                           result->size());
			break;
		}
		case WLR_XDG_SURFACE_ROLE_NONE:
			break;
	}
}

void xdg_surface_destroy(wl_listener* listener, void* data) {
	ZenithView* view = wl_container_of(listener, view, destroy);
	ZenithServer* server = view->server;

	std::cout << "erase surface " << view->xdg_surface->surface << std::endl;
	std::cout << "erase id " << view->id << std::endl;
	size_t erased = server->view_id_by_wlr_surface.erase(view->xdg_surface->surface);
	assert(erased == 1);
	erased = server->views_by_id.erase(view->id);
	assert(erased == 1);
}

void surface_commit(wl_listener* listener, void* data) {
	auto* surface = static_cast<wlr_surface*>(data);
	auto* server = ZenithServer::instance();

	auto it_id = server->view_id_by_wlr_surface.find(surface);
	bool view_doesnt_exist = it_id == server->view_id_by_wlr_surface.end();
	if (view_doesnt_exist) {
		// Not an xdg_surface, nothing to handle.
		return;
	}

	auto view = server->views_by_id.find(it_id->second)->second.get();
	wlr_xdg_surface* xdg_surface = view->xdg_surface;

	wlr_box new_geometry = xdg_surface->geometry;

	if (view->geometry.x != new_geometry.x
	    || view->geometry.y != new_geometry.y
	    || view->geometry.width != new_geometry.width
	    || view->geometry.height != new_geometry.height) {
		view->geometry = new_geometry;
		// TODO
	}

	server->surface_framebuffers_mutex.lock();

	auto it = server->surface_framebuffers.find(view->id);
	bool framebuffer_doesnt_exist = it == server->surface_framebuffers.end();
	if (framebuffer_doesnt_exist) {
		server->surface_framebuffers_mutex.unlock();
		return;
	}
	auto& surface_framebuffer = it->second;

	if (not((size_t) surface->current.buffer_width == surface_framebuffer->pending_width and
	        (size_t) surface->current.buffer_height == surface_framebuffer->pending_height)) {

		wlr_egl* egl = wlr_gles2_renderer_get_egl(server->renderer);
		wlr_egl_make_current(egl);

		// The actual resizing is happening on a Flutter thread because resizing a texture is very slow, and I don't want
		// to block the main thread causing input delay and other stuff.
		surface_framebuffer->schedule_resize(surface->current.buffer_width, surface->current.buffer_height);
		std::cout << "width: " << surface->current.buffer_width << " height: " << surface->current.buffer_height
		          << std::endl;

		auto value = EncodableValue(EncodableMap{
			  {EncodableValue("view_id"),        EncodableValue((int64_t) view->id)},
			  {EncodableValue("surface_role"),   EncodableValue(xdg_surface->role)},
			  {EncodableValue("surface_width"),  EncodableValue((int64_t) surface->current.buffer_width)},
			  {EncodableValue("surface_height"), EncodableValue((int64_t) surface->current.buffer_height)},
			  {EncodableValue("visible_bounds"), EncodableValue(EncodableMap{
					{EncodableValue("x"),      EncodableValue(xdg_surface->geometry.x)},
					{EncodableValue("y"),      EncodableValue(xdg_surface->geometry.y)},
					{EncodableValue("width"),  EncodableValue(xdg_surface->geometry.width)},
					{EncodableValue("height"), EncodableValue(xdg_surface->geometry.height)},
			  })}
		});
		auto result = StandardMethodCodec::GetInstance().EncodeSuccessEnvelope(&value);
		view->server->output->flutter_engine_state->messenger.Send("resize_surface", result->data(),
		                                                           result->size());
	}

	server->surface_framebuffers_mutex.unlock();
}

void xdg_toplevel_request_move(wl_listener* listener, void* data) {
	ZenithView* view = wl_container_of(listener, view, request_move);

	auto value = EncodableValue(EncodableMap{
		  {EncodableValue("view_id"), EncodableValue((int64_t) view->id)},
	});
	auto result = StandardMethodCodec::GetInstance().EncodeSuccessEnvelope(&value);
	view->server->output->flutter_engine_state->messenger.Send("request_move", result->data(),
	                                                           result->size());
}

void xdg_toplevel_request_resize(wl_listener* listener, void* data) {
	ZenithView* view = wl_container_of(listener, view, request_resize);
//	auto* event = static_cast<wlr_xdg_toplevel_resize_event*>(data);

	auto value = EncodableValue(EncodableMap{
		  {EncodableValue("view_id"), EncodableValue((int64_t) view->id)},
	});
	auto result = StandardMethodCodec::GetInstance().EncodeSuccessEnvelope(&value);
	view->server->output->flutter_engine_state->messenger.Send("request_resize", result->data(),
	                                                           result->size());
}