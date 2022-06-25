#!/bin/bash

set -e

PWD="$(echo $(pwd))"
TMP="$PWD/temp"
DATE_WITH_TIME=$(date "+%Y-%m-%d / %H:%M:%S")

if ! command -v zip >/dev/null; then
    echo "Please install zip (apt install zip)"
    exit 1
fi

if ! command -v zenity >/dev/null; then
    echo "Please install zenity (apt install zenity)"
    exit 1
fi

function color() {
    echo -e $@
}

function rep() {
    while getopts :n:c: OPTION; do
        case $OPTION in
        i)
            local INPUT="$OPTARG"
            ;;
        o)
            local OUTPUT="$OPTARG"
            ;;
        esac
    done
    sed "s/({$1})/$2/g" $INPUT >"$TMP/$OUTPUT"
}

MODULE_TYPE=$(
    zenity --forms \
        --title="Generate Module" \
        --text="Module Type" \
        --width="200" \
        --height="300" \
        --separator="," \
        --add-combo "Type" \
        --combo-values "Basic|Dynamic Installer"
)
accepted_type=$?
if ((accepted_type != 0)); then
    echo "something went wrong"
    exit 1
fi
MODULE_TYPE_LAG=$(awk -F, '{print $1}' <<<$MODULE_TYPE)

BUILD_PATH="$PWD/build"
if [ "$MODULE_TYPE_LAG" = "Basic" ]; then
    function MAKE_BASIC() {
        rm -rf "$PWD/build"
        [ ! -d "$BUILD_PATH" ] && mkdir -p "$BUILD_PATH"
        cp -r "$PWD/modules/basic/META-INF" "$PWD/build"

        local BASIC_MODULE=$(
            zenity --forms \
                --title="Generate Module" \
                --text="Enter" \
                --width="200" \
                --height="300" \
                --separator="," \
                --show-header \
                --add-entry="Id" \
                --add-entry="Name" \
                --add-entry="Author" \
                --add-entry="Description" \
                --add-entry="Donate URL" \
                --add-entry="Support Url" \
                --add-entry="Update JSON Url" \
                --add-entry="Config Package" \
                --add-combo "Change boot?" \
                --combo-values "true|false" \
                --add-combo "Needs ramdisk?" \
                --combo-values "true|false"
        )
        local accepted=$?
        if ((accepted != 0)); then
            echo "something went wrong"
            exit 1
        fi
        MODULE_ID=$(awk -F, '{print $1}' <<<$BASIC_MODULE)
        local MODULE_NAME=$(awk -F, '{print $2}' <<<$BASIC_MODULE)
        local MODULE_AUTHOR=$(awk -F, '{print $3}' <<<$BASIC_MODULE)
        local MODULE_DESCRIPTION=$(awk -F, '{print $4}' <<<$BASIC_MODULE)
        local MODULE_DONATE_URL=$(awk -F, '{print $5}' <<<$BASIC_MODULE)
        local MODULE_SUPPORT_URL=$(awk -F, '{print $6}' <<<$BASIC_MODULE)
        local MODULE_UPDATE_JSON_URL=$(awk -F, '{print $7}' <<<$BASIC_MODULE)
        local MODULE_CONFIG=$(awk -F, '{print $8}' <<<$BASIC_MODULE)
        local FOXMMM_CHANGE_BOOT=$(awk -F, '{print $9}' <<<$BASIC_MODULE)
        local FOXMMM_NEEDS_RAMDISK=$(awk -F, '{print $10}' <<<$BASIC_MODULE)

        # module.prop
        sed '/^[[:space:]]*$/d' <<EOF >${PWD}/build/module.prop
# Magisk properties
id=${MODULE_ID}
name=${MODULE_NAME}
version=v1.0.0
versionCode=1
author=${MODULE_AUTHOR}
description=${MODULE_DESCRIPTION}
$([ -z "$MODULE_UPDATE_JSON_URL" ] && echo "" || echo "updateJson=$MODULE_UPDATE_JSON_URL")

# FoxMMM properties
$([ -z "$FOXMMM_NEEDS_RAMDISK" ] && echo "" || echo "needRamdisk=$FOXMMM_NEEDS_RAMDISK")
$([ -z "$FOXMMM_CHANGE_BOOT" ] && echo "" || echo "changeBoot=$FOXMMM_CHANGE_BOOT")
$([ -z "$MODULE_SUPPORT_URL" ] && echo "" || echo "support=$MODULE_SUPPORT_URL")
$([ -z "$MODULE_DONATE_URL" ] && echo "" || echo "donate=$MODULE_DONATE_URL")
$([ -z "$MODULE_CONFIG" ] && echo "" || echo "config=$MODULE_CONFIG")
EOF

        cat <<EOF >${PWD}/build/customize.sh
ui_print "--------------------------------"
ui_print "$MODULE_NAME                          "
ui_print "1.0.0                       "
ui_print "--------------------------------"
ui_print "by $MODULE_AUTHOR                     "
ui_print "--------------------------------"
ui_print " "
ui_print "- Done"

EOF
    }
    MAKE_BASIC
else
    function MAKE_DYNAMIC() {
        zenity --info \
            --text="Dynamic Installer modules are not supported in FoxMMM."

        rm -rf "$PWD/build"
        [ ! -d "$BUILD_PATH" ] && mkdir -p "$BUILD_PATH"
        cp -r "$PWD/modules/dynamic_installer/META-INF" "$PWD/build"
        cp -r "$PWD/modules/dynamic_installer/test" "$PWD/build"

        local DYNAMIC_MODULE=$(
            zenity --forms \
                --title="Generate Module" \
                --text="Enter" \
                --width="200" \
                --height="300" \
                --separator="," \
                --show-header \
                --add-entry="Id" \
                --add-entry="Name" \
                --add-entry="Author" \
                --add-entry="Description" \
                --add-entry="Donate URL" \
                --add-entry="Support Url" \
                --add-entry="Update JSON Url" \
                --add-entry="Config Package" \
                --add-combo "Change boot?" \
                --combo-values "true|false" \
                --add-combo "Needs ramdisk?" \
                --combo-values "true|false" \
                --add-combo "Enable Magisk Support?" \
                --combo-values "on|off"
        )
        local accepted=$?
        if ((accepted != 0)); then
            echo "something went wrong"
            exit 1
        fi
        MODULE_ID=$(awk -F, '{print $1}' <<<$DYNAMIC_MODULE)
        local MODULE_NAME=$(awk -F, '{print $2}' <<<$DYNAMIC_MODULE)
        local MODULE_AUTHOR=$(awk -F, '{print $3}' <<<$DYNAMIC_MODULE)
        local MODULE_DESCRIPTION=$(awk -F, '{print $4}' <<<$DYNAMIC_MODULE)
        local MODULE_DONATE_URL=$(awk -F, '{print $5}' <<<$DYNAMIC_MODULE)
        local MODULE_SUPPORT_URL=$(awk -F, '{print $6}' <<<$DYNAMIC_MODULE)
        local MODULE_UPDATE_JSON_URL=$(awk -F, '{print $7}' <<<$DYNAMIC_MODULE)
        local MODULE_CONFIG=$(awk -F, '{print $8}' <<<$DYNAMIC_MODULE)
        local FOXMMM_CHANGE_BOOT=$(awk -F, '{print $9}' <<<$DYNAMIC_MODULE)
        local FOXMMM_NEEDS_RAMDISK=$(awk -F, '{print $10}' <<<$DYNAMIC_MODULE)
        local MODULE_SUPPORT_MAGISK=$(awk -F, '{print $11}' <<<$DYNAMIC_MODULE)

        # module.prop
        sed '/^[[:space:]]*$/d' <<EOF >${PWD}/build/META-INF/com/google/android/magisk/module.prop
# Magisk properties
id=${MODULE_ID}
name=${MODULE_NAME}
version=v1.0.0
versionCode=1
author=${MODULE_AUTHOR}
description=${MODULE_DESCRIPTION}
$([ -z "$MODULE_UPDATE_JSON_URL" ] && echo "" || echo "updateJson=$MODULE_UPDATE_JSON_URL")

# FoxMMM properties
$([ -z "$FOXMMM_NEEDS_RAMDISK" ] && echo "" || echo "needRamdisk=$FOXMMM_NEEDS_RAMDISK")
$([ -z "$FOXMMM_CHANGE_BOOT" ] && echo "" || echo "changeBoot=$FOXMMM_CHANGE_BOOT")
$([ -z "$MODULE_SUPPORT_URL" ] && echo "" || echo "support=$MODULE_SUPPORT_URL")
$([ -z "$MODULE_DONATE_URL" ] && echo "" || echo "donate=$MODULE_DONATE_URL")
$([ -z "$MODULE_CONFIG" ] && echo "" || echo "config=$MODULE_CONFIG")
EOF

        cat <<EOF >${PWD}/build/META-INF/com/google/android/magisk/customize.sh
import_config "\$MODPATH/module.prop"
chmodBin="\$addons/makeExecuteable.sh"

ui_print "--------------------------------"
ui_print "\$name                          "
ui_print "\$version                       "
ui_print "--------------------------------"
ui_print "by \$author                     "
ui_print "--------------------------------"
ui_print " "

# Extract test folder
package_extract_dir "test" "\$MODPATH/system/bin"

# Make test.sh execute able
\$chmodBin "\$MODPATH/system/bin/test.sh"

EOF

        cat <<EuF >${PWD}/build/META-INF/com/google/android/updater-script
# Before: ui_print("  Hi! ");
# Now:    ui_print " Hi! "
#-----------Dynamic Installer Configs-----------#
#The #MAGISK tag is required, dont remove it
#MAGISK
$([ -z "$MODULE_SUPPORT_MAGISK" ] && echo "setdefault magisk_support on" || echo "setdefault magisk_support $MODULE_SUPPORT_MAGISK")
setdefault run_addons off
setdefault apex_mount off
setdefault extraction_speed default
setdefault permissions "0:0:0755:0644"
setdefault devices off
#-----------------------------------------------#
#Your script starts here:
EuF
    }
    MAKE_DYNAMIC
fi

cd ./build
file="../output/${MODULE_ID}.zip"
rm -f $file
zip -r $file * .[^.]*

echo "Your module has been zipped saved in the output folder"
