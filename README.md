[chrome]: https://www.google.com/chrome/

# Module-Tamplate-Generator

The script generates you an simple module for Magisk.

## Building

```bash
# Run and follow the prompts
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

# Fox's Mmm supported properties
minApi=<int>
maxApi=<int>
minMagisk=<int>
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

The `customize.sh` is planted with my most common used functions and commands

```bash
#!/system/bin/sh

# Configurable while the building process
if [ -n "$MMM_EXT_SUPPORT" ]; then; ui_print "#!useExt"; mmm_exec() { ui_print "$(echo "#!$@")"; }; else; mmm_exec() { true; };abort "! This module need to be executed in Fox's Magisk Module Manager";exit 1;fi


srcDir="$(cd "\${0%/*}" \2\>/dev/null \|\| :\; echo "\$PWD")"

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
  sed -n "s|^$1@Q=||p" \${2:-\$srcDir/module.prop};
}

```
