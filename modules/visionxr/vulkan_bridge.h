
#ifdef USE_VOLK
#include <volk.h>
#else
#include <vulkan/vulkan.h>
#endif

class VulkanBridge {

public:
    static void vision_encode_present(VkExportMetalCommandBufferInfoEXT exportMetalCmdBufferObj);
};
