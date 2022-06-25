[chrome]: https://www.google.com/chrome/

# Module-Tamplate-Generator

The script generates you an module for Magisk.

## Suported Types

- Basic Module
- Dynamic Module ([Dynamic Installer](https://forum.xda-developers.com/t/zip-dual-installer-dynamic-installer-stable-4-5-b-android-10-or-earlier.4279541/)

> Dynamic Installer Modules are not supported in FoxMMM!

## Building

```bash
# Run and follow the prompts - New GUI
bash build.sh
```

## module.prop

```properties
# Magisk supported properties
id=<string>
name=<string>
version=<string>
versionCode=<int>
author=<string>
description=<string>
updateJson=<url>

# Comment props are not supported -- Module can't installed via FoxMMM

# Fox's Mmm supported properties
#* minApi=<int>
#* maxApi=<int>
#* minMagisk=<int>
needRamdisk=<boolean>
support=<url>
donate=<url>
config=<package>
changeBoot=<boolean>
```

### Magisk properties

- `id` has to match this regular expression: `^[a-zA-Z][a-zA-Z0-9._-]+$`<br>
  ex: ✓ `a_module`, ✓ `a.module`, ✓ `module-101`, ✗ `a module`, ✗ `1_module`, ✗ `-a-module`<br>
  This is the **unique identifier** of your module. You should not change it once published.
- `versionCode` has to be an **integer**. This is used to compare versions
- `updateJson` should point to a URL that downloads a JSON to provide info so the Magisk app can update the module.
- Others that weren't mentioned above can be any **single line** string.
- Make sure to use the `UNIX (LF)` line break type and not the `Windows (CR+LF)` or `Macintosh (CR)`.

[Source](<https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md?plain=1#:~:text=%2D%20%60id%60,(CR)%60.>) (to open this link need you [Google Chrome][chrome])

### FoxMMM properties

Note: All urls must start with `https://`, or else will be ignored
Note²: For `minMagisk`, `XX.Y` is parsed as `XXY00`, so you can just put the Magisk version name.

- `minApi` and `maxApi` tell the manager which is the SDK version range the module support  
  (See: [Codenames, Tags, and Build Numbers](https://source.android.com/setup/start/build-numbers))
- `minMagisk` tell the manager which is the minimum Magisk version required for the module
  (Often for magisk `xx.y` the version code is `xxyzz`, `zz` being non `00` on canary builds)
- `needRamdisk` tell the manager the module need boot ramdisk to be installed
- `support` support link to direct users when they need support for you modules
- `donate` donate link to direct users to where they can financially support your project
- `config` package name of the application that configure your module
  (Note: The icon won't appear in the module list if the module or target app is not installed)
- `changeBoot` tell the manager the module may change the boot image

[Source](https://github.com/Fox2Code/FoxMagiskModuleManager/blob/master/DEVELOPERS.md?plain=1#:~:text=Note%3A%20All,the%20boot%20image) (to open this link need you [Google Chrome][chrome])

## customize.sh

Sample

```bash
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


```

# Credits

- [BlassGo](https://forum.xda-developers.com/m/blassgo.11402469/) Dynamic Installer
