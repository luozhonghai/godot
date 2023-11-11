#include "visionxr_interface.h"

#include "core/string/print_string.h"
#include "servers/rendering/renderer_rd/effects/copy_effects.h"
#include "servers/rendering/renderer_rd/storage_rd/texture_storage.h"
#include "servers/rendering/rendering_server_globals.h"
#include "servers/rendering_server.h"
#include "vulkan_bridge.h"
#include "platform/visionos/display_server_visionos.h"
#include "platform/visionos/os_visionos.h"
#include "thirdparty/MoltenVK/mvk_config.h"

StringName VisionXRInterface::get_name() const {
	return StringName("VisionXR");
};

uint32_t VisionXRInterface::get_capabilities() const {
	return XRInterface::XR_VR + XRInterface::XR_AR;
}

RID VisionXRInterface::get_color_texture() {
	//return XRInterface::get_color_texture();
	//std::cout << "visionxr get_color_texture" << std::endl;
	return color_texture_rid;
}

RID VisionXRInterface::get_depth_texture() {
	//return XRInterface::get_depth_texture();
	//std::cout << "visionxr get_depth_texture" << std::endl;
	return depth_texture_rid;
}

bool VisionXRInterface::initialize_on_startup() const {
	return true;
}

bool VisionXRInterface::is_initialized() const {
	return initialized;
};

bool VisionXRInterface::initialize() {

	XRServer *xr_server = XRServer::get_singleton();
	ERR_FAIL_NULL_V(xr_server, false);


	_device = DisplayServerVISIONOS::get_singleton()->get_vkdevice();
	initialized = false;

	if (!initialized) {
		// MVKConfiguration config;
		// size_t len = sizeof(MVKConfiguration);
		// vkGetMoltenVKConfigurationMVK(nullptr, &config, &len);
		// config.prefillMetalCommandBuffers = MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS_STYLE_DEFERRED_ENCODING;
		// vkSetMoltenVKConfigurationMVK(nullptr, &config, &len);

		// we must create a tracker for our head
		// head.instantiate();
		// head->set_tracker_type(XRServer::TRACKER_HEAD);
		// head->set_tracker_name("head");
		// head->set_tracker_desc("Players head");
		// xr_server->add_tracker(head);

		// make this our primary interface
		xr_server->set_primary_interface(this);

		//last_ticks = OS::get_singleton()->get_ticks_usec();

		initialized = true;

		runWorldTrackingARSession();

		std::cout << "VisionXRInterface initialized." << std::endl;
	}
}

void VisionXRInterface::process() {
}

void VisionXRInterface::pre_render() {

	_frame = OS_VISIONOS::get_singleton()->getVisionFrame();
	cp_frame_timing_t timing = OS_VISIONOS::get_singleton()->getVisionTiming();

	cp_frame_end_update(_frame);
        
	cp_time_wait_until(cp_frame_timing_get_optimal_input_time(timing));
        
	cp_frame_start_submission(_frame);

	//std::cout << "cp_frame_start_submission " << std::endl;
	std::cout << "cp_frame_query_drawable ... " << std::endl;
	_drawable = cp_frame_query_drawable(_frame);
	if (_drawable == nullptr) {
		return;
	}

	std::cout << "cp_frame_query_drawable success " << std::endl;

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
	//std::cout << "visionxr interface cp_drawable_get_view_count: " << count << std::endl;
	return 1;
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
        .usage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .flags = 0,
    };
    image.extent.width = color_texture.width;
    image.extent.height = color_texture.height;
    image.extent.depth = color_texture.depth;
    
    /* create image */
    result = vkCreateImage(_device, &image, NULL, &color.image);

	color.format = color_format;

	RenderingServer *rendering_server = RenderingServer::get_singleton();
	//ERR_FAIL_NULL_V(rendering_server, false);
	RenderingDevice *rendering_device = rendering_server->get_rendering_device();
	//ERR_FAIL_NULL_V(rendering_device, false);

	RenderingDevice::DataFormat format = RenderingDevice::DATA_FORMAT_R16G16B16A16_SFLOAT;
	RenderingDevice::TextureSamples samples = RenderingDevice::TEXTURE_SAMPLES_1;
	uint64_t usage_flags = RenderingDevice::TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice::TEXTURE_USAGE_COLOR_ATTACHMENT_BIT | RD::TEXTURE_USAGE_INPUT_ATTACHMENT_BIT;

	uint32_t p_width = color_texture.width;
	uint32_t p_height = color_texture.height;

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

	color_texture_rid = image_rid;
}

void VisionXRInterface::prepareDepth(cp_drawable_t drawable, size_t index)
{
	VkResult result;
    const VkFormat depth_format = VK_FORMAT_D32_SFLOAT;

	id<MTLTexture> depth_texture = cp_drawable_get_depth_texture(drawable, index);
    VkImportMetalTextureInfoEXT metal_import = {
                .sType      = VK_STRUCTURE_TYPE_IMPORT_METAL_TEXTURE_INFO_EXT,
                .plane      = VK_IMAGE_ASPECT_DEPTH_BIT,
                .mtlTexture = depth_texture
    };
    
    VkImageCreateInfo image = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .pNext = &metal_import,
        .imageType = VK_IMAGE_TYPE_2D,
        .format = depth_format,
        //.extent = {color_texture.width, color_texture.height, color_texture.depth},
        .mipLevels = 1,
        .arrayLayers = 1,
        .samples = VK_SAMPLE_COUNT_1_BIT,
        .tiling = VK_IMAGE_TILING_OPTIMAL,
        .usage = VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT,
        .flags = 0,
    };
    image.extent.width = depth_texture.width;
    image.extent.height = depth_texture.height;
    image.extent.depth = depth_texture.depth;
    
    /* create image */
    result = vkCreateImage(_device, &image, NULL, &depth.image);

	depth.format = depth_format;

	RenderingServer *rendering_server = RenderingServer::get_singleton();
	//ERR_FAIL_NULL_V(rendering_server, false);
	RenderingDevice *rendering_device = rendering_server->get_rendering_device();
	//ERR_FAIL_NULL_V(rendering_device, false);

    //RenderingDevice::DataFormat format = RenderingDevice::DATA_FORMAT_D16_UNORM;
	RenderingDevice::DataFormat format = RenderingDevice::DATA_FORMAT_D32_SFLOAT;
	RenderingDevice::TextureSamples samples = RenderingDevice::TEXTURE_SAMPLES_1;
	uint64_t usage_flags = RenderingDevice::TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice::TEXTURE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;

	uint32_t p_width = depth_texture.width;
	uint32_t p_height = depth_texture.height;

	target_size.width = p_width;
	target_size.height = p_height;


	RID image_rid = rendering_device->texture_create_from_extension(
				RenderingDevice::TEXTURE_TYPE_2D,
				format,
				samples,
				usage_flags,
				(uint64_t)depth.image,
				p_width,
				p_height,
				1,
				1);

	depth_texture_rid  = image_rid;
}

bool VisionXRInterface::pre_draw_viewport(RID p_render_target) 
{
	return true;
}

Vector<BlitToScreen> VisionXRInterface::post_draw_viewport(RID p_render_target, const Rect2 &p_screen_rect) 
{
	Vector<BlitToScreen> blit_to_screen;
	//cp_drawable_encode_present(drawable, exportMetalCmdBufferObj.mtlCommandBuffer);
	return blit_to_screen;
}

void VisionXRInterface::post_encode_present(id<MTLCommandBuffer> mtlCommandBuffer)
{
	//std::cout << "cp_drawable_encode_present " << std::endl;
	cp_drawable_encode_present(_drawable, mtlCommandBuffer);
}
void VisionXRInterface::end_frame() {

	//std::cout << "cp_frame_end_submission " << std::endl;
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


void VulkanBridge::vision_encode_present(VkExportMetalCommandBufferInfoEXT exportMetalCmdBufferObj)
{
    Ref<XRInterface> xr_interface;
    if (XRServer::get_singleton() != nullptr) {
		xr_interface = XRServer::get_singleton()->get_primary_interface();
		//todo: fix it
		((VisionXRInterface*)*xr_interface)->post_encode_present(exportMetalCmdBufferObj.mtlCommandBuffer);
	}
}

Transform3D VisionXRInterface::get_camera_transform() {
	_THREAD_SAFE_METHOD_

	Transform3D transform_for_eye;

	XRServer *xr_server = XRServer::get_singleton();
	ERR_FAIL_NULL_V(xr_server, transform_for_eye);

	if (initialized) {
		//float world_scale = xr_server->get_world_scale();

		// just scale our origin point of our transform
		//Transform3D _head_transform = head_transform;
		//_head_transform.origin *= world_scale;

		//transform_for_eye = (xr_server->get_reference_frame()) * _head_transform;
	}

	std::cout<< "visionxr get_camera_transform " << std::endl;

	return transform_for_eye;
}

Transform3D VisionXRInterface::get_transform_for_view(uint32_t p_view, const Transform3D &p_cam_transform) {
	_THREAD_SAFE_METHOD_

	Transform3D transform_for_eye;

	XRServer *xr_server = XRServer::get_singleton();
	ERR_FAIL_NULL_V(xr_server, transform_for_eye);

	std::cout<< "visionxr get_transform_for_view " << std::endl;

	return transform_for_eye;

}

Projection VisionXRInterface::get_projection_for_view(uint32_t p_view, double p_aspect, double p_z_near, double p_z_far) {
	_THREAD_SAFE_METHOD_

	Projection eye;

	//aspect = p_aspect;
	//eye.set_for_hmd(p_view + 1, p_aspect, intraocular_dist, display_width, display_to_lens, oversample, p_z_near, p_z_far);

	// Failed to get from our OpenXR device? Default to some sort of sensible camera matrix..
	eye.set_for_hmd(p_view + 1, 1.0, 6.0, 14.5, 4.0, 1.5, p_z_near, p_z_far);

	std::cout<< "visionxr get_projection_for_view near:  " << p_z_near  << ", camera far: " << p_z_far << std::endl;

	return eye;
};

Dictionary VisionXRInterface::get_system_info() {
	Dictionary dict;

	dict[SNAME("XRRuntimeName")] = String("Godot Vision XR interface");
	dict[SNAME("XRRuntimeVersion")] = String("");

	return dict;
}

void VisionXRInterface::uninitialize() {
	if (initialized) {
		// do any cleanup here...
		XRServer *xr_server = XRServer::get_singleton();
		if (xr_server != nullptr) {
			// if (head.is_valid()) {
			// 	xr_server->remove_tracker(head);

			// 	head.unref();
			// }

			if (xr_server->get_primary_interface() == this) {
				// no longer our primary interface
				xr_server->set_primary_interface(nullptr);
			}
		}

		initialized = false;
	};
};

