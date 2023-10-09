#ifndef VULKAN_CONTEXT_VISIONOS_H
#define VULKAN_CONTEXT_VISIONOS_H
#ifdef VULKAN_ENABLED

#include "drivers/vulkan/vulkan_context.h"

class VulkanContextVISIONOS : public VulkanContext
{
	virtual const char *_get_platform_surface_extension() const;

public:
    VulkanContextVISIONOS(/);
    ~VulkanContextVISIONOS();
};

#endif // VULKAN_ENABLED

#endif // VULKAN_CONTEXT_VISIONOS_H
