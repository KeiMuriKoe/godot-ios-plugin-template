//
//  godot_plugin_implementation.mm
//

#import <Foundation/Foundation.h>

#include "core/config/project_settings.h"

#import "godot_plugin_implementation.h"

#import "godot_plugin-Swift.h"


void GodotPlugin::_bind_methods() {
	ClassDB::bind_method(D_METHOD("foo"), &GodotPlugin::foo);
}

Error GodotPlugin::foo() {
	NSLog(@"GodotPlugin foo");
    [GodotSwiftModule helloWorldFromSwift];
	return OK;
}

GodotPlugin::GodotPlugin() {
	NSLog(@"GodotPlugin constructor");
}

GodotPlugin::~GodotPlugin() {
	NSLog(@"GodotPlugin destructor");
}
