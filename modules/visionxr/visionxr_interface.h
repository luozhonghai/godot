
#ifndef VISIONXR_INTERFACE_H
#define VISIONXR_INTERFACE_H

#include "servers/xr/xr_interface.h"

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
	virtual void end_frame() override;

protected:
	static void _bind_methods();

};


#endif

