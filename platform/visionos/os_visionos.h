
#ifndef OS_VISIONOS_H
#define OS_VISIONOS_H

#ifdef VISIONOS_ENABLED
#import <CompositorServices/CompositorServices.h>
#include "drivers/unix/os_unix.h"
#include "servers/audio_server.h"
#include "servers/rendering/renderer_compositor.h"

#if defined(VULKAN_ENABLED)
#import "vulkan_context_visionos.h"

#include "drivers/vulkan/rendering_device_vulkan.h"
#endif


class OS_VISIONOS : public OS_Unix {
private:

	MainLoop *main_loop = nullptr;

	virtual void initialize_core() override;
	virtual void initialize() override;

	virtual void set_main_loop(MainLoop *p_main_loop) override;
	virtual MainLoop *get_main_loop() const override;

	bool is_focused = false;

	cp_layer_renderer_t _layerRenderer;

	cp_frame_t _frame;

	cp_frame_timing_t _timing;

	virtual void initialize_joypads() override {
	}

	virtual void delete_main_loop() override;

	virtual void finalize() override;

public:
	static OS_VISIONOS *get_singleton();

	cp_frame_t getVisionFrame();

	cp_frame_timing_t getVisionTiming();

	OS_VISIONOS(cp_layer_renderer_t layerRenderer);
	~OS_VISIONOS();

	void initialize_modules();

	void visionRunLoop();
	bool iterate();

	void start();
	void on_focus_out();
	void on_focus_in();

	virtual bool _check_internal_feature_support(const String &p_feature) override;


};

#endif

#endif
