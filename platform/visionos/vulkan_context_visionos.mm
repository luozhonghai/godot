
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

VulkanContextVISIONOS::VulkanContextVISIONOS() {}

VulkanContextVISIONOS::~VulkanContextVISIONOS() {}

#endif // VULKAN_ENABLED