#include <getopt.h>
#include <libinput.h>
#include <linux/input-event-codes.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
#include <wayland-server-core.h>
#include <thread>
#include <filesystem>
#include <climits>

// wlroots uses dumb-ass shit that makes it not compile on C++, let's fix that.
// https://github.com/swaywm/wlroots/issues/682
// pthread first because it uses class in a C++ way and XWayland includes that...
#include <pthread.h>

// #define class _class
// #define namespace _namespace
// #define static
// #define delete delete_
#define class
#define namespace
#define static
#define delete

extern "C" {
#include <wlr/backend.h>
#include <wlr/backend/libinput.h>
#include <wlr/backend/drm.h>
#include <wlr/render/allocator.h>
#include <wlr/render/wlr_renderer.h>
#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_cursor.h>
#include <wlr/types/wlr_data_control_v1.h>
#include <wlr/types/wlr_data_device.h>
#include <wlr/types/wlr_drm_lease_v1.h>
#include <wlr/types/wlr_drm.h>
#include <wlr/types/wlr_export_dmabuf_v1.h>
#include <wlr/types/wlr_linux_dmabuf_v1.h>
#include <wlr/types/wlr_gamma_control_v1.h>
#include <wlr/types/wlr_idle.h>
#include <wlr/types/wlr_input_device.h>
#include <wlr/types/wlr_keyboard.h>
#include <wlr/render/interface.h>
// #include <wlr/types/wlr_layer_shell_v1.h>
#include <wlr/types/wlr_matrix.h>
#include <wlr/types/wlr_output.h>
#include <wlr/types/wlr_output_layout.h>
#include <wlr/types/wlr_output_management_v1.h>
#include <wlr/types/wlr_pointer.h>
#include <wlr/types/wlr_presentation_time.h>
#include <wlr/types/wlr_primary_selection.h>
#include <wlr/types/wlr_primary_selection_v1.h>
#include <wlr/types/wlr_screencopy_v1.h>
#include <wlr/types/wlr_seat.h>
#include <wlr/types/wlr_server_decoration.h>
#include <wlr/types/wlr_viewporter.h>
#include <wlr/types/wlr_virtual_keyboard_v1.h>
#include <wlr/types/wlr_xcursor_manager.h>
#include <wlr/types/wlr_xdg_activation_v1.h>
#include <wlr/types/wlr_xdg_decoration_v1.h>
#include <wlr/types/wlr_xdg_output_v1.h>
#include <wlr/types/wlr_xdg_shell.h>
#include <wlr/types/wlr_subcompositor.h>
#include <wlr/types/wlr_scene.h>
#include <wlr/types/wlr_input_inhibitor.h>
#include <wlr/types/wlr_keyboard_shortcuts_inhibit_v1.h>
#include <wlr/types/wlr_virtual_pointer_v1.h>
#include <wlr/types/wlr_foreign_toplevel_management_v1.h>
#include <wlr/types/wlr_idle_inhibit_v1.h>
#include <wlr/util/log.h>
#include <wlr/util/region.h>
#include <wlr/render/swapchain.h>
// #include <wlr/types/wlr_tablet_pad.h>
// #include <wlr/types/wlr_tablet_tool.h>
// #include <wlr/types/wlr_tablet_v2.h>
#include <xkbcommon/xkbcommon.h>
#include <wlr/render/egl.h>
// #include <EGL/egl.h>
#include <wlr/render/gles2.h>
#include <wlr/render/allocator.h>
#include <wlr/render/wlr_texture.h>
// #include <wlr/types/wlr_pointer_constraints_v1.h>
#include <wlr/types/wlr_relative_pointer_v1.h>
#include <wlr/interfaces/wlr_keyboard.h>
#include <wlr/types/wlr_xdg_foreign_registry.h>
#include <wlr/types/wlr_xdg_foreign_v1.h>
#include <wlr/types/wlr_xdg_foreign_v2.h>
#include <wlr/types/wlr_pointer_gestures_v1.h>
// #include <wlr/types/wlr_output_power_management_v1.h>
#include <wlr/types/wlr_input_method_v2.h>
#include <wlr/types/wlr_text_input_v3.h>
#include <wlr/types/wlr_touch.h>
#include <wlr/types/wlr_switch.h>
#include <wlr/config.h>
#include <wlr/backend/headless.h>
#include <wlr/backend/multi.h>
#include <wlr/backend/wayland.h>
#include <wlr/types/wlr_session_lock_v1.h>
#include <wlr/types/wlr_single_pixel_buffer_v1.h>

// #include <wlr/xwayland/xwayland.h>

#include <libdrm/drm_fourcc.h>

// #if WLR_HAS_X11_BACKEND
// #include <wlr/backend/x11.h>
// #endif

}

#undef delete
#undef class
#undef namespace
#undef static

#include "util/wlr/wlr_helpers.hpp"