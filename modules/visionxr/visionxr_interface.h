
#ifndef VISIONXR_INTERFACE_H
#define VISIONXR_INTERFACE_H

#ifdef USE_VOLK
#include <volk.h>
#else
#include <vulkan/vulkan.h>
#endif
#include "servers/xr/xr_interface.h"
#import <Foundation/Foundation.h>
#import <CompositorServices/CompositorServices.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <ARKit/ARKit.h>
#import <Spatial/Spatial.h>

class VisionXRInterface : public XRInterface{
	GDCLASS(VisionXRInterface, XRInterface);

public:
	virtual StringName get_name() const override;
	virtual uint32_t get_capabilities() const override;

	virtual RID get_color_texture() override;
	virtual RID get_depth_texture() override;

	virtual void process() override;
	virtual void pre_render() override;
	bool pre_draw_viewport(RID p_render_target) override;
	virtual Vector<BlitToScreen> post_draw_viewport(RID p_render_target, const Rect2 &p_screen_rect) override; /* inform XR interface we finished our viewport draw process */

	virtual void end_frame() override;

	bool initialize_on_startup() const;
	virtual bool is_initialized() const override;
	virtual bool initialize() override;

	virtual void uninitialize() override;
	virtual Dictionary get_system_info() override;

	virtual uint32_t get_view_count() override;
	virtual Size2 get_render_target_size() override;

	void post_encode_present(id<MTLCommandBuffer> mtlCommandBuffer);

	virtual Transform3D get_camera_transform() override;
	virtual Transform3D get_transform_for_view(uint32_t p_view, const Transform3D &p_cam_transform) override;
	virtual Projection get_projection_for_view(uint32_t p_view, double p_aspect, double p_z_near, double p_z_far) override;

protected:
	static void _bind_methods();

	Size2 target_size;

private:

	// at a minimum we need a tracker for our head
	//Ref<XRPositionalTracker> head;
	//Transform3D head_transform;

	typedef struct {
        VkFormat format;

        VkImage image;
        VkMemoryAllocateInfo mem_alloc;
        VkDeviceMemory mem;
        VkImageView view;
    } CustomAttachment;

    CustomAttachment depth,color;

	VkDevice _device = nullptr;
	bool initialized = false;
	cp_frame_t _frame;
	cp_drawable_t _drawable;

	Vector<RID> color_texture_rids;
	Vector<RID> depth_texture_rids;

	ar_session_t _arSession;
    ar_world_tracking_provider_t _worldTrackingProvider;

	void prepareDepth(cp_drawable_t drawable, size_t index);
    void prepareColor(cp_drawable_t drawable, size_t index);

	ar_device_anchor_t createPoseForTiming(cp_frame_timing_t timing) {
        //ar_pose_t outPose = ar_pose_create();
        ar_device_anchor_t outDeviceAnchor = ar_device_anchor_create();

        cp_time_t presentationTime = cp_frame_timing_get_presentation_time(timing);
        CFTimeInterval queryTime = cp_time_to_cf_time_interval(presentationTime);
        ar_device_anchor_query_status_t status = ar_world_tracking_provider_query_device_anchor_at_timestamp(_worldTrackingProvider, queryTime, outDeviceAnchor);
        if (status != ar_device_anchor_query_status_success) {
            NSLog(@"Failed to get estimated pose from world tracking provider for presentation timestamp %0.3f", queryTime);
        }
        return outDeviceAnchor;
    }

	void runWorldTrackingARSession() {
        ar_world_tracking_configuration_t worldTrackingConfiguration = ar_world_tracking_configuration_create();
        _worldTrackingProvider = ar_world_tracking_provider_create(worldTrackingConfiguration);

        ar_data_providers_t dataProviders = ar_data_providers_create_with_data_providers(_worldTrackingProvider, nil);

        _arSession = ar_session_create();
        ar_session_run(_arSession, dataProviders);
    }


};


inline Size2 VisionXRInterface::get_render_target_size() {
	return target_size;
}



#endif

