#include "visionxr_interface.h"

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

void VisionXRInterface::process() {
}

void VisionXRInterface::pre_render() {
	//prepare color and depth texture
}

bool VisionXRInterface::pre_draw_viewport(RID p_render_target) {
	return true;
}

void VisionXRInterface::end_frame() {

	//cp_frame_end_submission(frame);
}

void VisionXRInterface::_bind_methods() {

	// todo: lifecycle signals from visionos
	// ADD_SIGNAL(MethodInfo("session_begun"));
	// ADD_SIGNAL(MethodInfo("session_stopping"));
	// ADD_SIGNAL(MethodInfo("session_focussed"));
	// ADD_SIGNAL(MethodInfo("session_visible"));
	// ADD_SIGNAL(MethodInfo("pose_recentered"));
};

