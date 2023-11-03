
#import "vulkan_context_visionos.h"

#ifdef VULKAN_ENABLED

#ifdef USE_VOLK
#include <volk.h>
#else
#include <vulkan/vulkan.h>
#endif

const char *VulkanContextVISIONOS::_get_platform_surface_extension() const {
	return VK_EXT_METAL_SURFACE_EXTENSION_NAME;
}

Error VulkanContextVISIONOS::window_create(DisplayServer::WindowID p_window_id, DisplayServer::VSyncMode p_vsync_mode, CAMetalLayer *p_metal_layer, int p_width, int p_height) {
	VkMetalSurfaceCreateInfoEXT createInfo;
	createInfo.sType = VK_STRUCTURE_TYPE_IOS_SURFACE_CREATE_INFO_MVK;
	createInfo.pNext = nullptr;
	createInfo.flags = 0;
	createInfo.pLayer = p_metal_layer;

	VkSurfaceKHR surface;
	VkResult err =
			vkCreateMetalSurfaceEXT(get_instance(), &createInfo, nullptr, &surface);
	ERR_FAIL_COND_V(err, ERR_CANT_CREATE);

	return _window_create(p_window_id, p_vsync_mode, surface, p_width, p_height);
}

VulkanContextVISIONOS::VulkanContextVISIONOS() {}

VulkanContextVISIONOS::~VulkanContextVISIONOS() {}

#endif // VULKAN_ENABLED