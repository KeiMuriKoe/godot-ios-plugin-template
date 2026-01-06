//
//  godot_plugin_implementation.h
//

#ifndef godot_plugin_implementation_h
#define godot_plugin_implementation_h

#include "core/object/object.h"
#include "core/object/class_db.h"

class GodotPlugin : public Object {
	GDCLASS(GodotPlugin, Object);
	
	static void _bind_methods();
	
public:
	
	void hello_world();
    
    void test_simple_signal();
    void test_data_signal(const String &message);
    void test_swift_void();
    void test_swift_data();
	
	GodotPlugin();
	~GodotPlugin();
};

#endif /* godot_plugin_implementation_h */
