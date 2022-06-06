#!/system/bin/sh

srcDir="/home/jimmy/Documents/GitHub/Module-Tamplate-Generator"

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