#import "os_visionos.h"

#ifdef VISIONOS_ENABLED

#import "display_server_visionos.h"
#include "main/main.h"
#if defined(VULKAN_ENABLED)
#include "servers/rendering/renderer_rd/renderer_compositor_rd.h"


#ifdef USE_VOLK
#include <volk.h>
#else
#include <vulkan/vulkan.h>
#endif
#endif


OS_VISIONOS *OS_VISIONOS::get_singleton() {
	return (OS_VISIONOS *)OS::get_singleton();
}

OS_VISIONOS::OS_VISIONOS(cp_layer_renderer_t layerRenderer) :
	_layerRenderer(layerRenderer) 
{
	DisplayServerVISIONOS::register_ios_driver();
}

OS_VISIONOS::~OS_VISIONOS() {}


void OS_VISIONOS::initialize_core() {
	OS_Unix::initialize_core();
}

void OS_VISIONOS::initialize() {
	initialize_core();
}

void OS_VISIONOS::initialize_modules() {

	Main::setup2();
	start();

	is_focused = true;
	visionRunLoop();
}

void OS_VISIONOS::visionRunLoop() {
	while (is_focused) {
		@autoreleasepool {
			switch (cp_layer_renderer_get_state(_layerRenderer)) {
				case cp_layer_renderer_state_paused:
					cp_layer_renderer_wait_until_running(_layerRenderer);
					break;
					
				case cp_layer_renderer_state_running:
					iterate();
					break;
					
					
				case cp_layer_renderer_state_invalidated:
					is_focused = false;
					break;
			}
		}
	}
}

void OS_VISIONOS::set_main_loop(MainLoop *p_main_loop) {
	main_loop = p_main_loop;

	if (main_loop) {
		main_loop->initialize();
	}
}

MainLoop *OS_VISIONOS::get_main_loop() const {
	return main_loop;
}

void OS_VISIONOS::delete_main_loop() {
	if (main_loop) {
		main_loop->finalize();
		memdelete(main_loop);
	}

	main_loop = nullptr;
}

bool OS_VISIONOS::iterate() {
	if (!main_loop) {
		return true;
	}

	cp_frame_t frame = cp_layer_renderer_query_next_frame(_layerRenderer);
    if (frame == nullptr) {
        return true;
    }

	_frame = frame;

    cp_frame_timing_t timing = cp_frame_predict_timing(frame);
    if (timing == nullptr) {
        return true;
    }

    cp_frame_start_update(frame);

	if (DisplayServer::get_singleton()) {
		DisplayServer::get_singleton()->process_events();
	}

	return Main::iteration();
}

//called from visionxr interface
void cp_frame_t OS_VISIONOS::getVisionFrame() {
	return _frame;
}

void OS_VISIONOS::start() {
	Main::start();

}

void OS_VISIONOS::on_focus_out() {
	if (is_focused) {
		is_focused = false;


		//[AppDelegate.viewController.godotView stopRendering];
		//disable [godot_view_renderer renderOnView]
		//then disable self OS_IOS::iterate

	}
}

void OS_VISIONOS::on_focus_in() {
	if (!is_focused) {
		is_focused = true;

		//[AppDelegate.viewController.godotView startRendering];

	}
}


#endif
