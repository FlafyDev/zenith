#pragma once
#include "../wlr-includes.hpp"

#include <wayland-server.h>
#include <list>
#include <mutex>
#include <unordered_map>
#include <memory>
#include <thread>
#include <unordered_set>
#include "output.hpp"
#include "input/keyboard.hpp"
#include "input/pointer.hpp"
#include "input/touch.hpp"
#include "input/text_input.hpp"
#include "surfaces/zenith_xdg_surface.hpp"
#include "surfaces/zenith_subsurface.hpp"
#include "surfaces/zenith_xdg_toplevel.hpp"
#include "surfaces/zenith_xdg_popup.hpp"
#include "util/rethreading/callable_queue.hpp"
#include "util/offset.hpp"
#include "flutter_engine/embedder_state.hpp"
// #include "xwayland.hpp"
#include "zenith_toplevel_decoration.hpp"


struct ZenithServer {
private:
	ZenithServer();

	static ZenithServer* _instance;

public:
	static ZenithServer* instance();

	void run(const char* startup_command);

	std::thread::id main_thread_id;
	std::string startup_command{};
	float display_scale = 1.0f;

	wl_display* display;
	wlr_backend* backend;
	wlr_renderer* renderer;
	wlr_allocator* allocator;
  wlr_session* session;
	wlr_compositor* compositor;
	wlr_subcompositor* subcompositor;
	wlr_xdg_shell* xdg_shell;
  // wlr_xwayland* xwayland;
	wlr_text_input_manager_v3* text_input_manager;
	wlr_xdg_decoration_manager_v1* decoration_manager;
	wlr_server_decoration_manager* server_decoration_manager;
	wlr_data_device_manager* data_device_manager;

	wlr_output_layout* output_layout;
	std::vector<std::shared_ptr<ZenithOutput>> outputs = {};
	std::shared_ptr<ZenithOutput> output = {}; // We support a single output at the moment.

	// The maximum size a window can be, which is basically the size of the screen minus the status bar and possibly
	// other decorations.
	// It's initialized with some dummy values but Flutter will notify the embedder about the available space when
	// widgets are constructed.
	Size max_window_size = {
		  .width = 0,
		  .height = 0,
	};
	bool start_windows_maximized = false;

	wl_listener new_output{};
	wl_listener new_surface{};
	wl_listener new_xdg_surface{};
	wl_listener new_input{};
	wl_listener request_cursor{};
	wl_listener new_text_input{};
	wl_listener new_toplevel_decoration{};
	wl_listener new_server_decoration{};
	wl_listener request_set_selection{};
  wl_listener xwayland_new_surface{};
  wl_listener xwayland_ready{};

	std::unordered_map<size_t, std::shared_ptr<ZenithSurface>> surfaces{};
	std::unordered_map<size_t, std::shared_ptr<ZenithSubsurface>> subsurfaces{};
	std::unordered_map<size_t, std::shared_ptr<ZenithXdgSurface>> xdg_surfaces{};
	std::unordered_map<size_t, std::shared_ptr<ZenithXdgToplevel>> xdg_toplevels{};
	std::unordered_map<size_t, std::shared_ptr<ZenithXdgPopup>> xdg_popups{};
	// std::unordered_map<size_t, std::shared_ptr<ZenithXWaylandSurface>> xwayland_surfaces{};
	// std::unordered_map<size_t, std::shared_ptr<ZenithToplevelDecoration>> toplevel_decorations{};

	wlr_seat* seat;
	std::unique_ptr<ZenithPointer> pointer;
	std::list<std::unique_ptr<ZenithKeyboard>> keyboards{};
	std::list<std::unique_ptr<ZenithTouchDevice>> touch_devices{};
	std::unordered_set<ZenithTextInput*> text_inputs{};

	std::unique_ptr<EmbedderState> embedder_state{};

	std::unordered_map<size_t, std::shared_ptr<SurfaceBufferChain<wlr_buffer>>> surface_buffer_chains{};

	CallableQueue callable_queue{};
};

bool is_main_thread();

/*
 * This event is raised by the backend when a new input device becomes available.
 */
void server_new_input(wl_listener* listener, void* data);

/*
 * This event is raised by the seat when a client provides a cursor image.
 */
void server_seat_request_cursor(wl_listener* listener, void* data);

void server_seat_request_set_selection(wl_listener* listener, void* data);
