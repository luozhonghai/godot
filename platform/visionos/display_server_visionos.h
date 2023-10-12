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

public:
	String rendering_driver;

	static DisplayServerVISIONOS *get_singleton();

#if defined(VULKAN_ENABLED)
	VkDevice get_vkdevice() { return _device; }
#endif

	static void register_visionos_driver();
	static DisplayServer *create_func(const String &p_rendering_driver, WindowMode p_mode, DisplayServer::VSyncMode p_vsync_mode, uint32_t p_flags, const Vector2i *p_position, const Vector2i &p_resolution, int p_screen, Error &r_error);
	static Vector<String> get_rendering_drivers_func();

};

#endif // DISPLAY_SERVER_VISIONOS_H
