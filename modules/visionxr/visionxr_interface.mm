#include "visionxr_interface.h"

#include "core/string/print_string.h"
#include "servers/rendering/renderer_rd/effects/copy_effects.h"
#include "servers/rendering/renderer_rd/storage_rd/texture_storage.h"
#include "servers/rendering/rendering_server_globals.h"
#include "servers/rendering_server.h"

StringName VisionXRInterface::get_name() const {
	return StringName("VisionXR");
};

uint32_t VisionXRInterface::get_capabilities() const {
	return XRInterface::XR_VR + XRInterface::XR_AR;
}

RID VisionXRInterface::get_color_texture() {
	return XRInterface::get_color_texture();
}

RID VisionXRInterface::get_depth_texture() {
	return XRInterface::get_depth_texture();
}

bool VisionXRInterface::initialize_on_startup() const {
	return true;
}

bool VisionXRInterface::is_initialized() const {
	return initialized;
};

bool VisionXRInterface::initialize() {
	_device = DisplayServerVISIONOS::get_singleton()->get_vkdevice();
	initialized = true;

	MVKConfiguration config;
    size_t len = sizeof(MVKConfiguration);
    vkGetMoltenVKConfigurationMVK(nullptr, &config, &len);
    config.prefillMetalCommandBuffers = MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS_STYLE_DEFERRED_ENCODING;
    vkSetMoltenVKConfigurationMVK(nullptr, &config, &len);
}

void VisionXRInterface::process() {
}

void VisionXRInterface::pre_render() {

	_frame = OS_VISIONOS::getVisionFrame();
	cp_frame_timing_t timing = OS_VISIONOS::getVisionTiming();

	cp_frame_end_update(frame);
        
	cp_time_wait_until(cp_frame_timing_get_optimal_input_time(timing));
        
	cp_frame_start_submission(frame);
	_drawable = cp_frame_query_drawable(frame);
	if (_drawable == nullptr) {
		return;
	}

	cp_frame_timing_t actualTiming = cp_drawable_get_frame_timing(_drawable);
	ar_device_anchor_t pose = createPoseForTiming(actualTiming);
	cp_drawable_set_device_anchor(_drawable, pose);

	//prepare color and depth texture
	//_renderer->drawAndPresent(frame, drawable);

	int count = cp_drawable_get_view_count(_drawable);
	color_texture_rids.resize(count);
	depth_texture_rids.resize(count); 

	//for (int i = 0; i < count; ++i) {

		prepareColor(_drawable, 0);
		prepareDepth(_drawable, 0);


	//}

	

}

uint32_t VisionXRInterface::get_view_count() {
	// TODO set this based on our configuration
	int count = cp_drawable_get_view_count(_drawable);
	return count;
}


void VisionXRInterface::prepareColor(cp_drawable_t drawable, size_t index)
{
	VkResult result;
    const VkFormat color_format = VK_FORMAT_R16G16B16A16_SFLOAT;

	id<MTLTexture> color_texture = cp_drawable_get_color_texture(drawable, index);
    VkImportMetalTextureInfoEXT metal_import = {
                .sType      = VK_STRUCTURE_TYPE_IMPORT_METAL_TEXTURE_INFO_EXT,
                .plane      = VK_IMAGE_ASPECT_COLOR_BIT,
                .mtlTexture = color_texture
    };
    
    VkImageCreateInfo image = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .pNext = &metal_import,
        .imageType = VK_IMAGE_TYPE_2D,
        .format = color_format,
        //.extent = {color_texture.width, color_texture.height, color_texture.depth},
        .mipLevels = 1,
        .arrayLayers = 1,
        .samples = VK_SAMPLE_COUNT_1_BIT,
        .tiling = VK_IMAGE_TILING_OPTIMAL,
        .usage = VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT,
        .flags = 0,
    };
    image.extent.width = color_texture.width;
    image.extent.height = color_texture.height;
    image.extent.depth = color_texture.depth;
    
    /* create image */
    result = vkCreateImage(_device, &image, NULL, &color.image);

	color.format = color_format;

	RenderingServer *rendering_server = RenderingServer::get_singleton();
	ERR_FAIL_NULL_V(rendering_server, false);
	RenderingDevice *rendering_device = rendering_server->get_rendering_device();
	ERR_FAIL_NULL_V(rendering_device, false);

	RenderingDevice::DataFormat format = RenderingDevice::DATA_FORMAT_R16G16B16A16_SFLOAT;
	RenderingDevice::TextureSamples samples = RenderingDevice::TEXTURE_SAMPLES_1;
	uint64_t usage_flags = RenderingDevice::TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice::TEXTURE_USAGE_COLOR_ATTACHMENT_BIT;

	uint32_t p_width = color_texture.width;
	uint32_t p_height = color_texture.width;

	target_size.width = p_width;
	target_size.height = p_height;


	RID image_rid = rendering_device->texture_create_from_extension(
				RenderingDevice::TEXTURE_TYPE_2D,
				format,
				samples,
				usage_flags,
				(uint64_t)color.image,
				p_width,
				p_height,
				1,
				1);

	color_texture_rids[index] = image_rid;
}

void VisionXRInterface::prepareDepth(cp_drawable_t drawable, size_t index)
{
	
}

bool VisionXRInterface::pre_draw_viewport(RID p_render_target) {
	return true;
}

void VisionXRInterface::end_frame() {

	cp_frame_end_submission(_frame);
}

void VisionXRInterface::_bind_methods() {

	// todo: lifecycle signals from visionos
	// ADD_SIGNAL(MethodInfo("session_begun"));
	// ADD_SIGNAL(MethodInfo("session_stopping"));
	// ADD_SIGNAL(MethodInfo("session_focussed"));
	// ADD_SIGNAL(MethodInfo("session_visible"));
	// ADD_SIGNAL(MethodInfo("pose_recentered"));
};

