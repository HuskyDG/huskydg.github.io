# Hidden SELinux Permissive

## About

- Selinux Permissive is very bad. For Magisk, it causes Magisk cannot completely hidden if you are using MagiskHide or any hiding mechanism (Shamiko). Developer didn't address this problem yet. 
- This module will patch selinux to premissive all contexts, apply some denials for `untrusted_app`, `isolated_app` and enforce they. In short, it will make Selinux is enforced for normal apps but system contexts are in Permissive. 
- Download this module: [Click here](http://huskydg.github.io/safety_permissive.zip)

## Feature

- Fake SELinux Enforcing
- Hide SU processes

## Android x86 ROM Integration

- It's possible to include this patch into Android x86 project without having to rely on Magisk module.

- On Android rootfs build, apply this patch into `ramdisk.img`:

```
RAMDISK="./ramdisk.img" # patch to your ramdisk image
mkdir /dev/ramdisk
cd /dev/ramdisk && zcat "$RAMDISK" | cpio -iud && {
cat <<EOF >/dev/se.rule
permissive *
allow untrusted_app * * *
allow isolated_app * * *
deny untrusted_app untrusted_app process setcurrent
deny { untrusted_app isolated_app } * process dyntransition
deny isolated_app isolated_app process setcurrent
deny { untrusted_app isolated_app } adb_data_file  * * 
deny { untrusted_app isolated_app } rootfs file { read write }
deny { untrusted_app isolated_app } selinuxfs file { read write open }
deny { untrusted_app isolated_app } * property_service { set }
deny { untrusted_app isolated_app } display_service service_manager find
deny { untrusted_app isolated_app } keystore keystore_key *
deny init * file relabelto
enforce untrusted_app
enforce isolated_app
EOF
magiskpolicy --load /dev/ramdisk/sepolicy --save /dev/ramdisk/sepolicy --apply /dev/se.rule
[ ! -f "/dev/ramdisk/init.rc.bak" ] && cp /dev/ramdisk/init.rc /dev/ramdisk/init.rc.bak
cp /dev/ramdisk/init.rc.bak /dev/ramdisk/init.rc
cat <<EOF >>/dev/ramdisk/init.rc

  on post-fs-data
     exec u:r:su:s0 root root -- /system/bin/setenforce 1
EOF
} && { find * | cpio -o -H newc | gzip >"$RAMDISK"; }
```

- On system-as-root build, directly patch system: 
```
mount -o rw,remount / && {
cat <<EOF >/dev/se.rule
permissive *
allow untrusted_app * * *
allow isolated_app * * *
deny untrusted_app untrusted_app process setcurrent
deny { untrusted_app isolated_app } * process dyntransition
deny isolated_app isolated_app process setcurrent
deny { untrusted_app isolated_app } adb_data_file  * * 
deny { untrusted_app isolated_app } rootfs file { read write }
deny { untrusted_app isolated_app } selinuxfs file { read write open }
deny { untrusted_app isolated_app } * property_service { set }
deny { untrusted_app isolated_app } display_service service_manager find
deny { untrusted_app isolated_app } keystore keystore_key *
deny init * file relabelto
enforce untrusted_app
enforce isolated_app
EOF
if [ -f "/vendor/etc/selinux/precompiled_sepolicy" ]; do
magiskpolicy --load /vendor/etc/selinux/precompiled_sepolicy --save /vendor/etc/selinux/precompiled_sepolicy --apply /dev/se.rule
else 
magiskpolicy --load /sepolicy --save /sepolicy --apply /dev/se.rule
fi
cat <<EOF >>/system/etc/init/selinux_enforce.rc

  on property:sys.boot_completed=1
     exec u:r:su:s0 root root -- "/system/bin/setenforce 1"
EOF
}
```


## Changelogs

### v1.2

- Change SELinux mode to Enforcing after boot completed on Android 10+ to avoid breaking system.

### v1.1

- Add more denials for untrusted_app and isolated_app to bypass [MagiskDetector](http://github.com/vvb2060/MagiskDetector).

### v1.0

- Initial release
