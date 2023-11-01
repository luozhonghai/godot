
#include "register_types.h"
#include "visionxr_interface.h"

#ifdef TOOLS_ENABLED
#include "editor/editor_node.h"
#endif

#ifdef VISIONOS_ENABLED
static Ref<VisionXRInterface> visionxr_interface;
#endif


void initialize_visionxr_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	GDREGISTER_CLASS(VisionXRInterface);

#ifdef VISIONOS_ENABLED
	XRServer *xr_server= XRServer::get_singleton();
	if(xr_server) {
		visionxr_interface.instantiate();

		xr_server->add_interface(visionxr_interface);

		if (visionxr_interface->initialize_on_startup()) {
			visionxr_interface->initialize();
		}
	}
#endif

}

void uninitialize_visionxr_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

#ifdef VISIONOS_ENABLED
	if (visionxr_interface.is_valid()) {
		// uninitialize just in case
		if (visionxr_interface->is_initialized()) {
			visionxr_interface->uninitialize();
		}

		// unregister our interface from the XR server
		XRServer *xr_server = XRServer::get_singleton();
		if (xr_server) {
			if (xr_server->get_primary_interface() == visionxr_interface) {
				xr_server->set_primary_interface(Ref<XRInterface>());
			}
			xr_server->remove_interface(visionxr_interface);
		}

		// and release
		visionxr_interface.unref();
	}
#endif


}
