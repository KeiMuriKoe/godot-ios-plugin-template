source 'https://cdn.cocoapods.org/'
use_frameworks!

plugin_name = 'godot_plugin'

project "#{plugin_name}.xcodeproj"
workspace "#{plugin_name}"

target "#{plugin_name}" do
	platform :ios, '13.0'
	# pod 'add-dependency-here', '1.0.0'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end
end