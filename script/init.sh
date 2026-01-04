#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#
set -e

function display_help()
{
    echo
    ./script/echocolor.sh -y "The " -Y "$0 script" -y " initializes the repository with the name of plugin."
    echo
    ./script/echocolor.sh -Y "Syntax:"
    ./script/echocolor.sh -y "  $0 [-h] <name of plugin>"
    echo
    ./script/echocolor.sh -Y "Options:"
    ./script/echocolor.sh -y "  h   display usage information"
    echo
    ./script/echocolor.sh -Y "Examples:"
    ./script/echocolor.sh -y "     $> $0 'my_plugin'"
    echo
}

function display_status()
{
    echo
    ./script/echocolor.sh -c "********************************************************************************"
    ./script/echocolor.sh -c "* $1"
    ./script/echocolor.sh -c "********************************************************************************"
    echo
}

function display_error()
{
    ./script/echocolor.sh -r "$1"
}

if [ $# -eq 0 ]; then
  display_error "Error: Please provide the name of the plugin as an argument."
  echo
  display_help
  exit 1
fi

while getopts "h" option; do
    case $option in
        h)
            display_help
            exit;;
        \?)
            display_error "Error: invalid option"
            echo
            display_help
            exit;;
    esac
done

template_plugin_name="GodotPlugin"
template_plugin_name_snake_case="godot_plugin"
NEW_PLUGIN_NAME=$1
NEW_PLUGIN_NAME="${NEW_PLUGIN_NAME// /_}"   # replace spaces with underscore
NEW_PLUGIN_NAME="${NEW_PLUGIN_NAME//\-/_}"  # replace dashes with underscore
plugin_name_pascal_case=`echo $NEW_PLUGIN_NAME | perl -pe 's/(^|[_])./uc($&)/ge;s/[_]//g'`
plugin_name_snake_case=`echo $NEW_PLUGIN_NAME | perl -pe 's/([a-z0-9])([A-Z])/$1_\L$2/g' | perl -nE 'say lcfirst'`

display_status "Using \n*\t- '$NEW_PLUGIN_NAME' (Input) \n*\t- '$plugin_name_snake_case' (Snake) \n*\t- '$plugin_name_pascal_case' (Pascal)"
sed -i '' -e "s/$template_plugin_name/$plugin_name_pascal_case/g" script/build_plugin.sh
sed -i '' -e "s/$template_plugin_name_snake_case/$plugin_name_snake_case/g" script/build_plugin.sh


sed -i '' -e "s/$template_plugin_name_snake_case/$NEW_PLUGIN_NAME/g" script/build.sh

sed -i '' -e "s/$template_plugin_name/$plugin_name_pascal_case/g" script/install.sh
sed -i '' -e "s/$template_plugin_name_snake_case/$NEW_PLUGIN_NAME/g" SConstruct
sed -i '' -e "s/$template_plugin_name_snake_case/$NEW_PLUGIN_NAME/g" Podfile

# 2. Update GDIP config
GDIP_FILE="config/$template_plugin_name_snake_case.gdip"
sed -i '' -e "s/$template_plugin_name_snake_case/$plugin_name_snake_case/g" "$GDIP_FILE"
sed -i '' -e "s/__PLUGIN_NAME__/$plugin_name_pascal_case/g" "$GDIP_FILE"
sed -i '' -e "s|__PLUGIN_BINARY__|$plugin_name_snake_case/$plugin_name_snake_case.xcframework|g" "$GDIP_FILE"

# 3. Update C++/Obj-C Source Files (.h, .mm)
sed -i '' -e "s/$template_plugin_name_snake_case/$plugin_name_snake_case/g" $template_plugin_name_snake_case/*.h
sed -i '' -e "s/$template_plugin_name_snake_case/$plugin_name_snake_case/g" $template_plugin_name_snake_case/*.mm
sed -i '' -e "s/$template_plugin_name/$plugin_name_pascal_case/g" $template_plugin_name_snake_case/*.h
sed -i '' -e "s/$template_plugin_name/$plugin_name_pascal_case/g" $template_plugin_name_snake_case/*.mm

# =========================================================
# START SWIFT SUPPORT
# =========================================================

sed -i '' -e "s/${template_plugin_name}Swift/${plugin_name_pascal_case}Swift/g" $template_plugin_name_snake_case/$template_plugin_name.swift

sed -i '' -e "s/${template_plugin_name}Swift/${plugin_name_pascal_case}Swift/g" $template_plugin_name_snake_case/*.mm

sed -i '' -e "s/${template_plugin_name_snake_case}-Swift.h/${plugin_name_snake_case}-Swift.h/g" $template_plugin_name_snake_case/*.mm

sed -i '' -e "s/$template_plugin_name.swift/$plugin_name_pascal_case.swift/g" $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/${template_plugin_name_snake_case}-Bridging-Header.h/${plugin_name_snake_case}-Bridging-Header.h/g" $template_plugin_name_snake_case.xcodeproj/project.pbxproj

# =========================================================
# END SWIFT SUPPORT
# =========================================================

# 4. Update Xcode Project Contents (General)
sed -i '' -e "s/$template_plugin_name_snake_case.xcodeproj/$NEW_PLUGIN_NAME.xcodeproj/g" \
    $template_plugin_name_snake_case.xcodeproj/project.xcworkspace/contents.xcworkspacedata

sed -i '' -e "s/$template_plugin_name_snake_case.h/$plugin_name_snake_case.h/g" \
    $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/$template_plugin_name_snake_case.mm/$plugin_name_snake_case.mm/g" \
    $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/${template_plugin_name_snake_case}_implementation.h/${plugin_name_snake_case}_implementation.h/g" \
    $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/${template_plugin_name_snake_case}_implementation.mm/${plugin_name_snake_case}_implementation.mm/g" \
    $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/$template_plugin_name_snake_case.a/$plugin_name_snake_case.a/g" \
    $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/$template_plugin_name_snake_case/$NEW_PLUGIN_NAME/g" \
    $template_plugin_name_snake_case.xcodeproj/project.pbxproj

# 5. RENAME DIRECTORIES AND FILES ON DISK

# Rename main folder
mv $template_plugin_name_snake_case $NEW_PLUGIN_NAME

# Rename config
mv config/$template_plugin_name_snake_case.gdip config/$plugin_name_snake_case.gdip

# Rename xcode project
mv $template_plugin_name_snake_case.xcodeproj $NEW_PLUGIN_NAME.xcodeproj

# Rename Source Files (Obj-C/C++)
mv $NEW_PLUGIN_NAME/$template_plugin_name_snake_case.h $NEW_PLUGIN_NAME/$plugin_name_snake_case.h
mv $NEW_PLUGIN_NAME/$template_plugin_name_snake_case.mm $NEW_PLUGIN_NAME/$plugin_name_snake_case.mm
mv $NEW_PLUGIN_NAME/${template_plugin_name_snake_case}_implementation.h $NEW_PLUGIN_NAME/${plugin_name_snake_case}_implementation.h
mv $NEW_PLUGIN_NAME/${template_plugin_name_snake_case}_implementation.mm $NEW_PLUGIN_NAME/${plugin_name_snake_case}_implementation.mm

mv $NEW_PLUGIN_NAME/$template_plugin_name.swift $NEW_PLUGIN_NAME/$plugin_name_pascal_case.swift
mv $NEW_PLUGIN_NAME/${template_plugin_name_snake_case}-Bridging-Header.h $NEW_PLUGIN_NAME/${plugin_name_snake_case}-Bridging-Header.h