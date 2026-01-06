//
//  godot_plugin_implementation.mm
//

#import <Foundation/Foundation.h>
#include "core/config/project_settings.h"
#import "godot_plugin_implementation.h"
#import "godot_plugin-Swift.h"

// Signal Names
String const SIGNAL_SIMPLE = "on_simple_signal";
String const SIGNAL_WITH_DATA = "on_data_signal";
String const SIGNAL_FROM_SWIFT_VOID = "on_swift_void_signal";
String const SIGNAL_FROM_SWIFT_DATA = "on_swift_data_signal";

void GodotPlugin::_bind_methods() {
    // Bind methods from .h
    ClassDB::bind_method(D_METHOD("hello_world"), &GodotPlugin::hello_world);
    
    ClassDB::bind_method(D_METHOD("test_simple_signal"), &GodotPlugin::test_simple_signal);
    ClassDB::bind_method(D_METHOD("test_data_signal", "message"), &GodotPlugin::test_data_signal);
    ClassDB::bind_method(D_METHOD("test_swift_void"), &GodotPlugin::test_swift_void);
    ClassDB::bind_method(D_METHOD("test_swift_data"), &GodotPlugin::test_swift_data);
    //
    
    // 2. Register Signals
    // Signal 1: Empty from .mm
    ADD_SIGNAL(MethodInfo(SIGNAL_SIMPLE));
    
    // Signal 2: With Parameter (String) from .mm
    ADD_SIGNAL(MethodInfo(SIGNAL_WITH_DATA, PropertyInfo(Variant::STRING, "message")));
    
    // Signal 3: Empty from Swift
    ADD_SIGNAL(MethodInfo(SIGNAL_FROM_SWIFT_VOID));
    
    // Signal 4: With parameter from Swift
    ADD_SIGNAL(MethodInfo(SIGNAL_FROM_SWIFT_DATA, PropertyInfo(Variant::STRING, "swift_data")));
}

//hello world message from .mm and .swift
void GodotPlugin::hello_world() {
    NSLog(@"GodotPlugin - Hello world from Objective C++!");
    [GodotPluginSwift helloWorldFromSwift];
}


// --- Direct C++ Signals ---

void GodotPlugin::test_simple_signal() {
    NSLog(@"GodotPlugin: Emitting simple signal directly");
    emit_signal(SIGNAL_SIMPLE);
}

void GodotPlugin::test_data_signal(const String &message) {
    NSLog(@"GodotPlugin: Emitting data signal directly");
    emit_signal(SIGNAL_WITH_DATA, message);
}

// --- Signals from Swift ---

void GodotPlugin::test_swift_void() {
    NSLog(@"GodotPlugin: Calling Swift task...");
    
    // We need a pointer to 'this' instance to use inside the block
    GodotPlugin *plugin_instance = this;
    
    // Create Swift instance
    GodotPluginSwift *swift = [[GodotPluginSwift alloc] init];
    
    // Call Swift method with a completion block (Closure)
    [swift doSwiftTaskWithCompletion:^ {
        NSLog(@"GodotPlugin: Swift task done. Emitting signal deferred.");
        
        // SAFETY: Use call_deferred because Swift might call this from a background thread
        plugin_instance->call_deferred("emit_signal", SIGNAL_FROM_SWIFT_VOID);
    }];
}

void GodotPlugin::test_swift_data() {
    NSLog(@"GodotPlugin: Requesting data from Swift...");
    
    GodotPlugin *plugin_instance = this;
    GodotPluginSwift *swift = [[GodotPluginSwift alloc] init];
    
    [swift getSwiftDataWithCompletion:^(NSString * _Nonnull result) {
        NSLog(@"GodotPlugin: Received data from Swift: %@", result);
        
        // Convert NSString to Godot String
        String godot_string = String(result.UTF8String);
        
        // Emit signal with data safely
        plugin_instance->call_deferred("emit_signal", SIGNAL_FROM_SWIFT_DATA, godot_string);
    }];
}

GodotPlugin::GodotPlugin() {
    NSLog(@"GodotPlugin constructor");
}

GodotPlugin::~GodotPlugin() {
    NSLog(@"GodotPlugin destructor");
}
