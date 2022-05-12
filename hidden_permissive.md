# Hidden SELinux Permissive

## About

- Selinux Permissive is very bad. For Magisk, it causes Magisk cannot completely hidden. SELinux Permissive will cause some Magisk traces to be more easily detected. An example when SELinux is Permissive, any apps can switch to u:r:magisk:s0 context to verify magisk, Enforcing normally prevent apps from switching context.
- Most Android x86 come with SELinux Permissive because developer can't address this problem. 

## What does it do?

- This module will patch selinux to premissive all contexts, apply some denials for `untrusted_app`, `isolated_app` and enforce they. In short, it will make Selinux is enforced for normal apps but system contexts are in Permissive. 
- Download this module: [Click here](http://huskydg.github.io/safety_permissive.zip)

## Feature

- Fake SELinux Enforcing
- Hide SU processes
- Hide Magisk UDS and state (Oprek Detection)
- Hide read-write rootfs (Oprek Detection)
- Prevent normal apps from changing system property
- Prevent normal apps from switching contexts to detect Magisk (`u:r:magisk:s0`)


## Changelogs

### v1.2

- Change SELinux mode to Enforcing after boot completed on Android 10+ to avoid breaking system.

### v1.1

- Add more denials for untrusted_app and isolated_app to bypass [MagiskDetector](http://github.com/vvb2060/MagiskDetector).

### v1.0

- Initial release


## Android x86 ROM Integration

- It's possible to include this patch into Android x86 project without having to rely on Magisk module. You must have `magiskpolicy` tool in order to patch.

- On Android rootfs build, apply this patch into `ramdisk.img`:

```
RAMDISK="./ramdisk.img" # patch to your ramdisk image
rm -rf /dev/ramdisk
mkdir /dev/ramdisk
cd /dev/ramdisk && zcat "$RAMDISK" | cpio -iud && wget https://raw.githubusercontent.com/HuskyDG/huskydg.github.io/main/se.rule -O /dev/se.rule && {
magiskpolicy --load /dev/ramdisk/sepolicy --save /dev/ramdisk/sepolicy --apply /dev/se.rule
[ ! -f "/dev/ramdisk/init.rc.bak" ] && cp /dev/ramdisk/init.rc /dev/ramdisk/init.rc.bak
cp /dev/ramdisk/init.rc.bak /dev/ramdisk/init.rc
cat <<EOF >>/dev/ramdisk/init.rc

  on post-fs-data
     exec u:r:su:s0 root root -- /system/bin/setenforce 1
     chmod 751 /

  on property:sys.boot_completed=1
     chmod 660 /sys/fs/selinux/enforce
     chmod 440 /sys/fs/selinux/policy
     chmod 440 /proc/net/unix
EOF
} && { find * | cpio -o -H newc | gzip >"$RAMDISK"; }
rm -rf /dev/ramdisk
```

- On system-as-root build, directly patch system: 

```
mount -o rw,remount / && wget https://raw.githubusercontent.com/HuskyDG/huskydg.github.io/main/se.rule -O /dev/se.rule && {
if [ -f "/vendor/etc/selinux/precompiled_sepolicy" ]; then
magiskpolicy --load /vendor/etc/selinux/precompiled_sepolicy --save /vendor/etc/selinux/precompiled_sepolicy --apply /dev/se.rule
else 
magiskpolicy --load /sepolicy --save /sepolicy --apply /dev/se.rule
fi
cat <<EOF >>/system/etc/init/selinux_enforce.rc

  on property:sys.boot_completed=1
     exec u:r:su:s0 root root -- /system/bin/setenforce 1
     chmod 660 /sys/fs/selinux/enforce
     chmod 440 /sys/fs/selinux/policy
     chmod 440 /proc/net/unix
EOF
}
```

