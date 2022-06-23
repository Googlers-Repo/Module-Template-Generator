import_config "$MODPATH/module.prop"
chmodBin="$addons/makeExecuteable.sh"

ui_print "--------------------------------"
ui_print "$name                          "
ui_print "$version                       "
ui_print "--------------------------------"
ui_print "by $author                     "
ui_print "--------------------------------"
ui_print " "

# Extract test folder
package_extract_dir "test" "$MODPATH/system/bin"

# Make test.sh execute able
$chmodBin "$MODPATH/system/bin/test.sh"

