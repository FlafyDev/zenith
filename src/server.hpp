#pragma once

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
#include "view.hpp"
#include "offset.hpp"
#include "channel.hpp"

extern "C" {
#define static
#include <wlr/backend.h>
#define class class_variable
#include <wlr/xwayland.h>
#undef class
#include <wlr/types/wlr_xdg_shell.h>
#include <wlr/types/wlr_output_layout.h>
#include <wlr/types/wlr_cursor.h>
#include <wlr/types/wlr_xcursor_manager.h>
#include <wlr/types/wlr_text_input_v3.h>
#include <wlr/types/wlr_xdg_decoration_v1.h>
#include <wlr/types/wlr_data_device.h>
#undef static
}

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
	wlr_compositor* compositor;
	wlr_xdg_shell* xdg_shell;
	wlr_text_input_manager_v3* text_input_manager;
	wlr_xdg_decoration_manager_v1* decoration_manager;
	wlr_data_device_manager* data_device_manager;

	wlr_output_layout* output_layout;
	std::unique_ptr<ZenithOutput> output; // We support a single output at the moment.

	// Box composed of all outputs.
	// A single Flutter engine doesn't support multi-window/multiscreen apps and cannot draw to multiple framebuffers.
	// If we are going to support multiple outputs in the future, we would have to create big framebuffer for all
	// outputs of the size of this box and reserve a portion of the framebuffer for each.
	// Right now, only one output is supported so the size of this box is essentially the size of the output.
	wlr_box output_layout_box{};

	// The maximum size a window can be, which is basically the size of the screen minus the status bar and possibly
	// other decorations.
	// It's initialized with some dummy values but Flutter will notify the embedder about the available space when
	// widgets are constructed.
	Size max_window_size = {
		  .width = 0,
		  .height = 0,
	};

	wl_listener new_output{};
	wl_listener new_xdg_surface{};
	wl_listener new_input{};
	wl_listener request_cursor{};
	wl_listener new_text_input{};
	wl_listener new_toplevel_decoration{};
	wl_listener request_set_selection{};

	std::unordered_map<size_t, ZenithView*> views{};
	std::unordered_map<size_t, std::shared_ptr<Framebuffer>> surface_framebuffers{};
	std::mutex surface_framebuffers_mutex{};

	wlr_seat* seat;
	std::unique_ptr<ZenithPointer> pointer;
	std::list<std::unique_ptr<ZenithKeyboard>> keyboards{};
	std::list<std::unique_ptr<ZenithTouchDevice>> touch_devices{};
	std::unordered_set<ZenithTextInput*> text_inputs{};
	std::unordered_map<int, Offset> leaf_surface_coords_per_device_id{};

	std::unique_ptr<EmbedderState> embedder_state{};
	int flutter_commit_output_fd;
	channel fb_channel{};
};

/*
 * This event is raised when a new output is detected, like a monitor or a projector.
 */
void server_new_output(wl_listener* listener, void* data);

/*
 * This event is raised when wlr_xdg_shell receives a new xdg surface from a
 * client, either a toplevel (application window) or popup.
 */
void server_new_xdg_surface(wl_listener* listener, void* data);

void xdg_surface_commit(wl_listener* listener, void* data);

/*
 * This event is raised by the backend when a new input device becomes available.
 */
void server_new_input(wl_listener* listener, void* data);

/*
 * This event is raised by the seat when a client provides a cursor image.
 */
void server_seat_request_cursor(wl_listener* listener, void* data);

void server_new_text_input(wl_listener* listener, void* data);

void server_new_toplevel_decoration(wl_listener* listener, void* data);

void server_seat_request_set_selection(wl_listener* listener, void* data);