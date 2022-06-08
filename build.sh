#!/bin/bash

PWD="$(echo $(pwd))"

if ! command -v zip > /dev/null;then
    echo "Please install zip (apt install zip)"
    exit 1
fi

function color() {
    echo -e $@
}

# Magisk props
read -p "$(color "Module \e[1mId \e[0m"): " MODULE_ID
read -p "$(color "Module \e[1mName \e[0m"): " MODULE_NAME
read -p "$(color "Module \e[1mAuthor \e[0m"): " MODULE_AUTHOR
read -p "$(color "Module \e[1mDescription \e[0m"): " MODULE_DESCRIPTION
echo "> Please read $(color "\e[38;5;82mhttps://source.android.com/setup/start/build-numbers\e[0m before!")"
read -p "$(color "Module \e[1mMinimal Android API \e[0m"): " MODULE_MIN_API
read -p "$(color "Module \e[1mMaximal Android API \e[0m"): " MODULE_MAX_API
echo -e "XX.Y is parsed as XXY00, so you can just put the $(color "\e[36mMagisk\e[0m") version name"
read -p "$(color "Module \e[1mMinimal Magisk version \e[0m"): " MODULE_MIN_MAGISK
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

# Aks if it should only executet in FoxMMM
while true; do
    read -p "Should this module $(color "\e[33monly\e[0m") installed via the FoxMMM? $(color "[\e[34my\e[0m/\e[34mn\e[0m]") " yn
    case $yn in
        [Yy]* ) EXECUTE_ONLY_FOXMMM="if [ -n \"\$MMM_EXT_SUPPORT\" ]; then; ui_print \"#!useExt\"; mmm_exec() { ui_print \"\$(echo \"#!\$@\")\"; }; else; mmm_exec() { true; };abort \"! This module need to be executed in Fox's Magisk Module Manager\";exit 1;fi"; break;;
        [Nn]* ) FORTNITE="JA DIGGAH"; break;;
        * ) echo "Please answer $(color "\e[34myes\e[0m or \e[34mno\e[0m").";;
    esac
done

for bin in MODULE_ID MODULE_NAME MODULE_DESCRIPTION MODULE_AUTHOR MODULE_SUPPORT_URL
do
    if [ -z "$bin" ]
    then
        echo "$bin is missing"
        exit 1
    fi
done

# .github/workflows/generate.yml
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
$([ -z "$MODULE_MIN_API" ] && echo "" || echo "minApi=$MODULE_MIN_API")
$([ -z "$MODULE_MAX_API" ] && echo "" || echo "maxApi=$MODULE_MAX_API")
$([ -z "$MODULE_MIN_MAGISK" ] && echo "" || echo "minMagisk=$MODULE_MIN_MAGISK")
needRamdisk=${FOXMMM_NEEDS_RAMDISK}
$([ -z "$MODULE_SUPPORT_URL" ] && echo "" || echo "support=$MODULE_SUPPORT_URL")
$([ -z "$MODULE_DONATE_URL" ] && echo "" || echo "donate=$MODULE_DONATE_URL")
$([ -z "$MODULE_CONFIG" ] && echo "" || echo "config=$MODULE_CONFIG")
changeBoot=${FOXMMM_CHANGE_BOOT}
EOF

cat <<EOF >${PWD}/build/customize.sh
#!/system/bin/sh

$([ -z "$EXECUTE_ONLY_FOXMMM" ] && echo "" || echo "$EXECUTE_ONLY_FOXMMM")

srcDir="\$(cd "\${0%/*}" \2\>/dev/null \|\| :\; echo "\$PWD")"

print() {
    ui_print \$@
}

chmodBin() {
    chmod +x \$MODPATH/system/bin/\$@  
}

systemWrite() {
    if [ \$1 = true ]; then
        mount -o rw,remount /
        print "System is now read/write"  
    elif [ \$1 = false ]; then
        mount -o ro,remount /
        print "System is now read-only"
    else
        print "System not writeable"
    fi
}

getProp() {
  sed -n "s|^\$1=||p" \${2:-\$srcDir/module.prop};
}

EOF

cd ./build
file="../output/${MODULE_ID}.zip"
rm -f $file
zip -r $file * .[^.]*

echo "Your module has been zipped saved in the output folder"
