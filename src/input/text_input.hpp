#pragma once

#include "../wlr-includes.hpp"

struct ZenithServer;

struct ZenithTextInput {
	explicit ZenithTextInput(wlr_text_input_v3* wlr_text_input);

	wlr_text_input_v3* wlr_text_input;

	wl_listener text_input_enable{};
	wl_listener text_input_disable{};
	wl_listener text_input_commit{};
	wl_listener text_input_destroy{};

	void enter(wlr_surface* surface) const;

	void leave() const;

	void disable() const;
};

void text_input_create_handle(wl_listener* listener, void* data);

void text_input_enable_handle(wl_listener* listener, void* data);

void text_input_disable_handle(wl_listener* listener, void* data);

void text_input_commit_handle(wl_listener* listener, void* data);

void text_input_destroy_handle(wl_listener* listener, void* data);
