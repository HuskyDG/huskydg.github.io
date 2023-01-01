#!/usr/bin/env bash
# This script will stop zygote, simulate the Magisk start up process
# that would've happened before zygote was started, and finally
# restart zygote. This is useful for setting up the emulator for
# developing Magisk, testing modules, and developing root apps using
# the official Android emulator (AVD) instead of a real device.
#
# This only covers the "core" features of Magisk. For testing
# magiskinit, please checkout avd_patch.sh.
#
#####################################################################

mkblknode(){
    local blk_mm="$(mountpoint -d "$2" | sed "s/:/ /g")"
    mknod "$1" -m 666 b $blk_mm
}

cd /data/local/tmp
chmod 755 busybox

if [ -z "$FIRST_STAGE" ]; then
  export FIRST_STAGE=1
  export ASH_STANDALONE=1
  if [ $(./busybox id -u) -ne 0 ]; then
    # Re-exec script with root
    exec /system/xbin/su 0 ./busybox sh $0
  else
    # Re-exec script with busybox
    exec ./busybox sh $0
  fi
fi

pm install -r $(pwd)/magisk.apk

# Extract files from APK
unzip -oj magisk.apk 'assets/util_functions.sh'
. ./util_functions.sh

api_level_arch_detect

unzip -oj magisk.apk "lib/$ABI/*" "lib/$ABI32/libmagisk32.so" -x "lib/$ABI/libbusybox.so"
for file in lib*.so; do
  chmod 755 $file
  mv "$file" "${file:3:${#file}-6}"
done

# Stop zygote (and previous setup if exists)
magisk --stop 2>/dev/null
stop
if [ -d /dev/avd-magisk ]; then
  umount -l /dev/avd-magisk 2>/dev/null
  rm -rf /dev/avd-magisk 2>/dev/null
fi

# SELinux stuffs
if [ -d /sys/fs/selinux ]; then
  if [ -f /vendor/etc/selinux/precompiled_sepolicy ]; then
    ./magiskpolicy --load /vendor/etc/selinux/precompiled_sepolicy --live --magisk 2>&1
  elif [ -f /sepolicy ]; then
    ./magiskpolicy --load /sepolicy --live --magisk 2>&1
  else
    ./magiskpolicy --live --magisk 2>&1
  fi
fi

MAGISKTMP=/sbin

# Setup bin overlay
if [ -d /sbin ]; then
  if $IS64BIT; then
    chmod 755 ./magisk64
    ./magisk64 --mount-sbin
  else
    chmod 755 ./magisk32
    ./magisk32 --mount-sbin
  fi
else
  # Android Q+ without sbin
  MAGISKTMP=/dev/avd-magisk
  mkdir /dev/avd-magisk
  mount -t tmpfs -o 'mode=0755' tmpfs /dev/avd-magisk
fi

# Magisk stuff
mkdir -p $MAGISKBIN 2>/dev/null
unzip -oj magisk.apk 'assets/*.sh' -d $MAGISKBIN
mkdir $NVBASE/modules 2>/dev/null
mkdir $POSTFSDATAD 2>/dev/null
mkdir $SERVICED 2>/dev/null

for file in magisk32 magisk64 magiskpolicy; do
  chmod 755 ./$file
  cp -af ./$file $MAGISKTMP/$file
  cp -af ./$file $MAGISKBIN/$file
done
cp -af ./magiskboot $MAGISKBIN/magiskboot
cp -af ./magiskinit $MAGISKBIN/magiskinit
cp -af ./busybox $MAGISKBIN/busybox

if $IS64BIT; then
  ln -s ./magisk64 $MAGISKTMP/magisk
else
  ln -s ./magisk32 $MAGISKTMP/magisk
fi
$MAGISKTMP/magisk --install $MAGISKTMP

./magiskinit -x manager $MAGISKTMP/stub.apk

mkdir -p $MAGISKTMP/.magisk/mirror
mkdir $MAGISKTMP/.magisk/block
touch $MAGISKTMP/.magisk/config

# Boot up
$MAGISKTMP/magisk --post-fs-data
while [ ! -f /dev/.magisk_unblock ];
do
  sleep 1
done
rm /dev/.magisk_unblock
# allow sepolicy.rule live patch
touch /dev/.magisk_livepatch 
$MAGISKTMP/magisk resetprop -n sys.boot_completed 0
start
$MAGISKTMP/magisk --service
rm /dev/.magisk_livepatch
sleep 1
while [ "$(getprop sys.boot_completed)" != "1" ];
do
  sleep 1
done
$MAGISKTMP/magisk --boot-complete


