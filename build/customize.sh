#!/system/bin/sh

if [ -n "$MMM_EXT_SUPPORT" ]; then; ui_print "#!useExt"; mmm_exec() { ui_print "$(echo "#!$@")"; }; else; mmm_exec() { true; };abort "! This module need to be executed in Fox's Magisk Module Manager";exit 1;fi

srcDir="$(cd "${0%/*}" \2\>/dev/null \|\| :\; echo "$PWD")"

print() {
    ui_print $@
}

chmodBin() {
    chmod +x $MODPATH/system/bin/$@  
}

systemWrite() {
    if [ $1 = true ]; then
        mount -o rw,remount /
        print "System is now read/write"  
    elif [ $1 = false ]; then
        mount -o ro,remount /
        print "System is now read-only"
    else
        print "System not writeable"
    fi
}

getProp() {
  sed -n "s|^$1=||p" ${2:-$srcDir/module.prop};
}

