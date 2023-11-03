#ifndef VULKAN_CONTEXT_VISIONOS_H
#define VULKAN_CONTEXT_VISIONOS_H
#ifdef VULKAN_ENABLED

#include "drivers/vulkan/vulkan_context.h"
#import <QuartzCore/CAMetalLayer.h>

class VulkanContextVISIONOS : public VulkanContext
{
	virtual const char *_get_platform_surface_extension() const;

public:

	Error window_create(DisplayServer::WindowID p_window_id, DisplayServer::VSyncMode p_vsync_mode, CAMetalLayer *p_metal_layer, int p_width, int p_height);

    VulkanContextVISIONOS();
    ~VulkanContextVISIONOS();
};

#endif // VULKAN_ENABLED

#endif // VULKAN_CONTEXT_VISIONOS_H
