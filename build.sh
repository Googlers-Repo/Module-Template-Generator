#!/bin/bash

set -e

PWD="$(echo $(pwd))"
TMP="$PWD/temp"
DATE_WITH_TIME=`date "+%Y-%m-%d / %H:%M:%S"`

if ! command -v zip > /dev/null;then
    echo "Please install zip (apt install zip)"
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
    sed "s/({$1})/$2/g"  $INPUT > "$TMP/$OUTPUT"
}

# Magisk props
read -p "$(color "Module \e[1mId \e[0m"): " MODULE_ID
read -p "$(color "Module \e[1mName \e[0m"): " MODULE_NAME
read -p "$(color "Module \e[1mAuthor \e[0m"): " MODULE_AUTHOR
read -p "$(color "Module \e[1mDescription \e[0m"): " MODULE_DESCRIPTION
echo "> Note: All urls must start with $(color "\e[33mhttps://\e[0m") or else will be ignored"
read -p "$(color "Module \e[1mDonate URL \e[0m"): " MODULE_DONATE_URL
read -p "$(color "Module \e[1mSupport URL \e[0m"): " MODULE_SUPPORT_URL
read -p "$(color "Module \e[1mUpdate JSON \e[0m"): " MODULE_UPDATE_JSON_URL
echo "> Note: Here are Android packages required! Like $(color "\e[4mcom.example.module.settings\e[24m")"
read -p "$(color "Module \e[1mConfig package \e[0m"): " MODULE_CONFIG

# Ask if change boot
while true; do
    read -p "Does your module $(color "\e[91mchange boot\e[0m") partition? $(color "[\e[34my\e[0m/\e[34mn\e[0m]") " yn
    case $yn in
        [Yy]* ) FOXMMM_CHANGE_BOOT="true"; break;;
        [Nn]* ) FOXMMM_CHANGE_BOOT="false"; break;;
        * ) echo "Please answer $(color "\e[34myes\e[0m or \e[34mno\e[0m").";;
    esac
done

# Aks if it needs ramdisk
while true; do
    read -p "Does your module $(color "\e[91mneeds ramdisk\e[0m")? $(color "[\e[34my\e[0m/\e[34mn\e[0m]") " yn
    case $yn in
        [Yy]* ) FOXMMM_NEEDS_RAMDISK="true"; break;;
        [Nn]* ) FOXMMM_NEEDS_RAMDISK="false"; break;;
        * ) echo "Please answer $(color "\e[34myes\e[0m or \e[34mno\e[0m").";;
    esac
done

for bin in MODULE_ID MODULE_NAME MODULE_DESCRIPTION MODULE_AUTHOR MODULE_SUPPORT_URL
do
    if [ -z "$bin" ] || [ "$bin" = "" ]
    then
        echo "$bin is missing"
        exit 1
    fi
done

# .github/workflows/generate.yml
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
needRamdisk=${FOXMMM_NEEDS_RAMDISK}
$([ -z "$MODULE_SUPPORT_URL" ] && echo "" || echo "support=$MODULE_SUPPORT_URL")
$([ -z "$MODULE_DONATE_URL" ] && echo "" || echo "donate=$MODULE_DONATE_URL")
$([ -z "$MODULE_CONFIG" ] && echo "" || echo "config=$MODULE_CONFIG")
changeBoot=${FOXMMM_CHANGE_BOOT}
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

cat <<EOF >${PWD}/build/META-INF/com/google/android/update-script
# Before: ui_print("  Hi! ");
# Now:    ui_print " Hi! "
#-----------Dynamic Installer Configs-----------#
#The #MAGISK tag is required, dont remove it
#MAGISK
setdefault magisk_support on
setdefault run_addons off
setdefault apex_mount off
setdefault extraction_speed default
setdefault permissions "0:0:0755:0644"
setdefault devices off
#-----------------------------------------------#
#Your script starts here:
EOF

cd ./build
file="../output/${MODULE_ID}.zip"
rm -f $file
zip -r $file * .[^.]*

echo "Your module has been zipped saved in the output folder"
