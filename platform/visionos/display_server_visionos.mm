
#import "display_server_visionos.h"
//parent(DisplayServer) constructor method will set singleton to this
DisplayServerVISIONOS *DisplayServerVISIONOS::get_singleton() {
	return (DisplayServerVISIONOS *)DisplayServer::get_singleton();
}

//created from main::setup2(), earlier than xr server/interface.
DisplayServerVISIONOS::DisplayServerVISIONOS(const String &p_rendering_driver, WindowMode p_mode, DisplayServer::VSyncMode p_vsync_mode, uint32_t p_flags, const Vector2i *p_position, const Vector2i &p_resolution, int p_screen, Error &r_error) {

    rendering_driver = p_rendering_driver;

#if defined(VULKAN_ENABLED)
	context_vulkan = nullptr;
	rendering_device_vulkan = nullptr;

    if (rendering_driver == "vulkan") {
		context_vulkan = memnew(VulkanContextVISIONOS);
		if (context_vulkan->initialize() != OK) {
			memdelete(context_vulkan);
			context_vulkan = nullptr;
			ERR_FAIL_MSG("Failed to initialize Vulkan context");
		}

        rendering_device_vulkan = memnew(RenderingDeviceVulkan);
		rendering_device_vulkan->initialize(context_vulkan);

		_device = context_vulkan->get_device();

		RendererCompositorRD::make_current();
    }
#endif
}

DisplayServerVISIONOS::~DisplayServerVISIONOS() {
#if defined(VULKAN_ENABLED)
	if (rendering_device_vulkan) {
		rendering_device_vulkan->finalize();
		memdelete(rendering_device_vulkan);
		rendering_device_vulkan = nullptr;
	}

	if (context_vulkan) {
		context_vulkan->window_destroy(MAIN_WINDOW_ID);
		memdelete(context_vulkan);
		context_vulkan = nullptr;
	}
#endif
}

DisplayServer *DisplayServerVISIONOS::create_func(const String &p_rendering_driver, WindowMode p_mode, DisplayServer::VSyncMode p_vsync_mode, uint32_t p_flags, const Vector2i *p_position, const Vector2i &p_resolution, int p_screen, Error &r_error) {
	return memnew(DisplayServerVISIONOS(p_rendering_driver, p_mode, p_vsync_mode, p_flags, p_position, p_resolution, p_screen, r_error));
}

Vector<String> DisplayServerVISIONOS::get_rendering_drivers_func() {
	Vector<String> drivers;

#if defined(VULKAN_ENABLED)
	drivers.push_back("vulkan");
#endif
#if defined(GLES3_ENABLED)
	drivers.push_back("opengl3");
#endif

	return drivers;
}

void DisplayServerVISIONOS::register_visionos_driver() {
	register_create_function("VISIONOS", create_func, get_rendering_drivers_func);
}

bool DisplayServerVISIONOS::has_feature(Feature p_feature) const {

	return false;
}

String DisplayServerVISIONOS::get_name() const {
	return "VisionOS";
}

int DisplayServerVISIONOS::get_screen_count() const {
	return 1;
}

int DisplayServerVISIONOS::get_primary_screen() const {
	return 0;
}

Point2i DisplayServerVISIONOS::screen_get_position(int p_screen) const {
	return Size2i();
}

Size2i DisplayServerVISIONOS::screen_get_size(int p_screen) const {
	return Size2i();
}

Rect2i DisplayServerVISIONOS::screen_get_usable_rect(int p_screen) const {
	return Rect2i(screen_get_position(p_screen), screen_get_size(p_screen));
}

int DisplayServerVISIONOS::screen_get_dpi(int p_screen) const {
  //temp
  return 132;
}

float DisplayServerVISIONOS::screen_get_refresh_rate(int p_screen) const {
	//return [UIScreen mainScreen].maximumFramesPerSecond;
	return 90;
}

float DisplayServerVISIONOS::screen_get_scale(int p_screen) const {
	return 1.0;
}

Vector<DisplayServer::WindowID> DisplayServerVISIONOS::get_window_list() const {
	Vector<DisplayServer::WindowID> list;
	list.push_back(MAIN_WINDOW_ID);
	return list;
}

DisplayServer::WindowID DisplayServerVISIONOS::get_window_at_screen_position(const Point2i &p_position) const {
	return MAIN_WINDOW_ID;
}

void DisplayServerVISIONOS::process_events() {
	//Input::get_singleton()->flush_buffered_events();
}
