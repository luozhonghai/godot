#ifndef DISPLAY_SERVER_VISIONOS_H
#define DISPLAY_SERVER_VISIONOS_H

#include "core/input/input.h"
#include "servers/display_server.h"

#if defined(VULKAN_ENABLED)
#import "vulkan_context_visionos.h"

#include "drivers/vulkan/rendering_device_vulkan.h"
#include "servers/rendering/renderer_rd/renderer_compositor_rd.h"

#ifdef USE_VOLK
#include <volk.h>
#else
#include <vulkan/vulkan.h>
#endif
#endif // VULKAN_ENABLED


class DisplayServerVISIONOS : public DisplayServer {
    // No need to register with GDCLASS, it's platform-specific and nothing is added.

	_THREAD_SAFE_CLASS_

#if defined(VULKAN_ENABLED)
	VulkanContextVISIONOS *context_vulkan = nullptr;
	RenderingDeviceVulkan *rendering_device_vulkan = nullptr;

	VkDevice _device;
#endif

	//construct from Main::setup2() 
    DisplayServerVISIONOS(const String &p_rendering_driver, DisplayServer::WindowMode p_mode, DisplayServer::VSyncMode p_vsync_mode, uint32_t p_flags, const Vector2i *p_position, const Vector2i &p_resolution, int p_screen, Error &r_error);
	~DisplayServerVISIONOS();

	ObjectID window_attached_instance_id;

public:
	String rendering_driver;

	static DisplayServerVISIONOS *get_singleton();

#if defined(VULKAN_ENABLED)
	VkDevice get_vkdevice() { return _device; }
#endif

	static void register_visionos_driver();
	static DisplayServer *create_func(const String &p_rendering_driver, WindowMode p_mode, DisplayServer::VSyncMode p_vsync_mode, uint32_t p_flags, const Vector2i *p_position, const Vector2i &p_resolution, int p_screen, Error &r_error);
	static Vector<String> get_rendering_drivers_func();

	virtual bool has_feature(Feature p_feature) const override;
	virtual String get_name() const override;

	virtual int get_screen_count() const override;
	virtual int get_primary_screen() const override;

	virtual Point2i screen_get_position(int p_screen = SCREEN_OF_MAIN_WINDOW) const override;
	virtual Size2i screen_get_size(int p_screen = SCREEN_OF_MAIN_WINDOW) const override;
	virtual Rect2i screen_get_usable_rect(int p_screen = SCREEN_OF_MAIN_WINDOW) const override;
	virtual int screen_get_dpi(int p_screen = SCREEN_OF_MAIN_WINDOW) const override;
	virtual float screen_get_scale(int p_screen = SCREEN_OF_MAIN_WINDOW) const override;
	virtual float screen_get_refresh_rate(int p_screen = SCREEN_OF_MAIN_WINDOW) const override;

	virtual Vector<DisplayServer::WindowID> get_window_list() const override;

	virtual WindowID
	get_window_at_screen_position(const Point2i &p_position) const override;


	virtual void window_set_rect_changed_callback(const Callable &p_callable, WindowID p_window = MAIN_WINDOW_ID) override{}
	virtual void window_set_window_event_callback(const Callable &p_callable, WindowID p_window = MAIN_WINDOW_ID) override{}
	virtual void window_set_input_event_callback(const Callable &p_callable, WindowID p_window = MAIN_WINDOW_ID) override{}
	virtual void window_set_input_text_callback(const Callable &p_callable, WindowID p_window = MAIN_WINDOW_ID) override{}
	virtual void window_set_drop_files_callback(const Callable &p_callable, WindowID p_window = MAIN_WINDOW_ID) override{}

	virtual void window_attach_instance_id(ObjectID p_instance, WindowID p_window = MAIN_WINDOW_ID) override{ window_attached_instance_id = p_instance; }
	virtual ObjectID window_get_attached_instance_id(WindowID p_window = MAIN_WINDOW_ID) const override {return window_attached_instance_id;} 

	virtual void window_set_title(const String &p_title, WindowID p_window = MAIN_WINDOW_ID) override{}

	virtual int window_get_current_screen(WindowID p_window = MAIN_WINDOW_ID) const override { return SCREEN_OF_MAIN_WINDOW; }
	virtual void window_set_current_screen(int p_screen, WindowID p_window = MAIN_WINDOW_ID) override {}

	virtual Point2i window_get_position(WindowID p_window = MAIN_WINDOW_ID) const override { return Point2i(); }
	virtual Point2i window_get_position_with_decorations(WindowID p_window = MAIN_WINDOW_ID) const override { return Point2i(); }
	virtual void window_set_position(const Point2i &p_position, WindowID p_window = MAIN_WINDOW_ID) override {}

	virtual void window_set_transient(WindowID p_window, WindowID p_parent) override {}

	virtual void window_set_max_size(const Size2i p_size, WindowID p_window = MAIN_WINDOW_ID) override {}
	virtual Size2i window_get_max_size(WindowID p_window = MAIN_WINDOW_ID) const override { return Size2i(); }

	virtual void window_set_min_size(const Size2i p_size, WindowID p_window = MAIN_WINDOW_ID) override {}
	virtual Size2i window_get_min_size(WindowID p_window = MAIN_WINDOW_ID) const override { return Size2i(); }

	virtual void window_set_size(const Size2i p_size, WindowID p_window = MAIN_WINDOW_ID) override {}
	virtual Size2i window_get_size(WindowID p_window = MAIN_WINDOW_ID) const override { return Size2i(); }
	virtual Size2i window_get_size_with_decorations(WindowID p_window = MAIN_WINDOW_ID) const override { return Size2i(); }

	virtual void window_set_mode(WindowMode p_mode, WindowID p_window = MAIN_WINDOW_ID) override {}
	virtual WindowMode window_get_mode(WindowID p_window = MAIN_WINDOW_ID) const override { return WindowMode::WINDOW_MODE_FULLSCREEN; }

	virtual bool window_is_maximize_allowed(WindowID p_window = MAIN_WINDOW_ID) const override {return true;}

	virtual void window_set_flag(WindowFlags p_flag, bool p_enabled, WindowID p_window = MAIN_WINDOW_ID) override {}
	virtual bool window_get_flag(WindowFlags p_flag, WindowID p_window = MAIN_WINDOW_ID) const override {return true; }

	virtual void window_request_attention(WindowID p_window = MAIN_WINDOW_ID) override {}
	virtual void window_move_to_foreground(WindowID p_window = MAIN_WINDOW_ID) override {}
	virtual bool window_is_focused(WindowID p_window = MAIN_WINDOW_ID) const override {return true; }

	virtual float screen_get_max_scale() const override { return 1.0f; }

	virtual bool window_can_draw(WindowID p_window = MAIN_WINDOW_ID) const override { return true; }

	virtual bool can_any_window_draw() const override { return true; }

	virtual void process_events() override;

	virtual void window_set_vsync_mode(DisplayServer::VSyncMode p_vsync_mode, WindowID p_window = MAIN_WINDOW_ID) override;
	virtual DisplayServer::VSyncMode window_get_vsync_mode(WindowID p_vsync_mode) const override;


};

#endif // DISPLAY_SERVER_VISIONOS_H
