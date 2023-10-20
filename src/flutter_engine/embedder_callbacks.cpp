#include "embedder_callbacks.hpp"
#include "embedder_state.hpp"
#include "server.hpp"
#include "util/rect.hpp"
#include "wlr/util/log.h"


#include <cassert>
#include <iostream>
#include <sys/eventfd.h>
#include <unistd.h>
#include <GL/gl.h>
#include <wlr/render/swapchain.h>

static wlr_buffer* swapchain_acquire_by_age(wlr_swapchain* swapchain, int age) {
  wlr_swapchain_slot* chosen_slot = nullptr;
	for (size_t i = 0; i < WLR_SWAPCHAIN_CAP; i++) {
		struct wlr_swapchain_slot *slot = &swapchain->slots[i];
    wlr_log(WLR_ERROR, "swapchain buffer #%i %p: %i", i, slot->buffer, slot->age);
    if (slot->age == age) {
      chosen_slot = slot;
    }
	}
  if (chosen_slot == nullptr) {
    return nullptr;
  }
  wlr_buffer_lock(chosen_slot->buffer);
  return chosen_slot->buffer;
}

// Acquires the oldest buffer in the swapchain. If 2+ buffers have the same age the function prefers the lastest of them.
static wlr_buffer* swapchain_acquire_oldest(wlr_swapchain* swapchain) {
  wlr_swapchain_slot* oldest_slot;
  int oldest_age = -1;
	for (size_t i = 0; i < WLR_SWAPCHAIN_CAP; i++) {
		struct wlr_swapchain_slot *slot = &swapchain->slots[i];
    wlr_log(WLR_ERROR, "swapchain buffer #%i %p: %i", i, slot->buffer, slot->age);
    if (slot->age >= oldest_age) {
      oldest_age = slot->age;
      oldest_slot = slot;
    }
	}
  if (oldest_slot == nullptr) {
    return nullptr;
  }
  wlr_buffer_lock(oldest_slot->buffer);
  return oldest_slot->buffer;
}

bool flutter_make_current(void* userdata) {
  wlr_log(WLR_ERROR, "flutter make current");
	auto* state = static_cast<EmbedderState*>(userdata);
	return wlr_egl_make_current(state->flutter_gl_context);
}

bool flutter_clear_current(void* userdata) {
	auto* state = static_cast<EmbedderState*>(userdata);
	return wlr_egl_unset_current(state->flutter_gl_context);
}

uint32_t flutter_fbo_callback(void* userdata) {
	auto* state = static_cast<EmbedderState*>(userdata);
	ZenithServer* server = ZenithServer::instance();

	wlr_buffer* buffer = server->output->swap_chain->start_write();


	// struct wlr_buffer *buffer = swapchain_acquire_by_age(server->output->swap_chain.get(), 0);
  // if (buffer == nullptr) {
  //   buffer = swapchain_acquire_oldest(server->output->swap_chain.get());
  // }
  // wlr_log(WLR_ERROR, "fbo: %p", buffer);
  // if (buffer == nullptr) {
  //   return false;
  // }

  server->renderer->impl->bind_buffer(state->flutter_renderer, buffer);

  // wlr_buffer_unlock(buffer);
  uint32_t res = wlr_gles2_renderer_get_current_fbo(state->flutter_renderer);
  return res;
}

bool flutter_present(void* userdata, const FlutterPresentInfo* present_info) {
  // Wait for the buffer to finish rendering before we commit it to the screen.
  glFinish();


  array_view<FlutterRect> frame_damage(present_info->frame_damage.damage, present_info->frame_damage.num_rects);

  // return true;
  ZenithServer* server = ZenithServer::instance();

	server->output->swap_chain->end_write(frame_damage);
  // wlr_buffer_lock(buffer);
  return true;
}

void flutter_vsync_callback(void* userdata, intptr_t baton) {
	auto* state = static_cast<EmbedderState*>(userdata);
	state->set_baton(baton);
}

bool flutter_gl_external_texture_frame_callback(void* userdata, int64_t texture_id, size_t width, size_t height,
                                                FlutterOpenGLTexture* texture_out) {
	auto* state = static_cast<EmbedderState*>(userdata);
	ZenithServer* server = ZenithServer::instance();
	const int64_t& view_id = texture_id;
	channel<wlr_gles2_texture_attribs> texture_attribs{};

	server->callable_queue.enqueue([&]() {
		std::scoped_lock lock(state->buffer_chains_mutex);
		auto find_client_chain = [&]() -> std::shared_ptr<SurfaceBufferChain<wlr_buffer>> {
			auto it = state->buffer_chains_in_use.find(view_id);
			if (it != state->buffer_chains_in_use.end()) {
				return it->second;
			}
			it = server->surface_buffer_chains.find(view_id);
			if (it != server->surface_buffer_chains.end()) {
				state->buffer_chains_in_use[view_id] = it->second;
				return it->second;
			}
			return nullptr;
		};

		const auto& client_chain = find_client_chain();

		if (client_chain == nullptr) {
			texture_attribs.write({});
			return;
		}

		wlr_buffer* buffer = client_chain->start_read();
		assert(buffer != nullptr);

		wlr_texture* texture = wlr_client_buffer_get(buffer)->texture;
		assert(texture != nullptr);

		wlr_gles2_texture_attribs attribs{};
		wlr_gles2_texture_get_attribs(texture, &attribs);
		texture_attribs.write(attribs);
		return;
	});

	wlr_gles2_texture_attribs attribs = texture_attribs.read();
	if (attribs.tex == 0) {
		return false;
	}

	texture_out->target = attribs.target;
	texture_out->format = GL_RGBA8;
	texture_out->name = attribs.tex;
	texture_out->user_data = (void*) view_id;

	texture_out->destruction_callback = [](void* user_data) {
		auto* server = ZenithServer::instance();
		auto view_id = reinterpret_cast<int64_t>(user_data);
		server->callable_queue.enqueue([=]() {
			std::scoped_lock lock(server->embedder_state->buffer_chains_mutex);

			auto& buffer_chains_in_use = server->embedder_state->buffer_chains_in_use;

			auto it = buffer_chains_in_use.find(view_id);
			if (it != buffer_chains_in_use.end()) {
				it->second->end_read();
			}
		});
	};

	return true;
}

void flutter_platform_message_callback(const FlutterPlatformMessage* message, void* userdata) {
	auto* state = static_cast<EmbedderState*>(userdata);

	if (message->struct_size != sizeof(FlutterPlatformMessage)) {
		std::cerr << "ERROR: Invalid message size received. Expected: "
		          << sizeof(FlutterPlatformMessage) << " but received "
		          << message->struct_size;
		return;
	}

	state->message_dispatcher.HandleMessage(*message, [] {}, [] {});
}

bool flutter_make_resource_current(void* userdata) {
	auto* state = static_cast<EmbedderState*>(userdata);
	return wlr_egl_make_current(state->flutter_resource_gl_context);
}

/*
 * The default rendering is done upside down for some reason.
 * This flips the rendering on the x-axis.
 */
FlutterTransformation flutter_surface_transformation(void* data) {
	channel<double> height_chan = {};
	auto* server = ZenithServer::instance();
	server->callable_queue.enqueue([server, &height_chan] {
		height_chan.write(server->output->wlr_output->height);
	});
	double height = height_chan.read();

	return FlutterTransformation{
		  1.0, 0.0, 0.0, 0.0, -1.0, height, 0.0, 0.0, 1.0,
	};
}

void flutter_populate_existing_damage(void* user_data, intptr_t fbo_id, FlutterDamage* existing_damage) {
	ZenithServer* server = ZenithServer::instance();
	existing_damage->struct_size = sizeof(FlutterDamage);
	existing_damage->num_rects = 1;

	array_view<FlutterRect> damage_regions = server->output->swap_chain->get_damage_regions();

	// TODO: Who should free this object? Me or Flutter?
	// Also, I think Flutter's partial repaint mechanism is not completely implemented.
	// It only works with one rectangle. If I give it more than one, it just ignores them.
	// For this reason we just combine all damage regions into one rectangle.
	auto* union_region = new FlutterRect{};
	if (damage_regions.size() > 0) {
		*union_region = damage_regions[0];
		for (size_t i = 1; i < damage_regions.size(); i++) {
			*union_region = rect_union(*union_region, damage_regions[i]);
		}
	}

	existing_damage->struct_size = sizeof(FlutterDamage);
	existing_damage->num_rects = 1;
	existing_damage->damage = union_region;
}
