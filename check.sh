# detect some traces
test ! -z "$LD_PRELPAD" && echo "Found LD_PRELOAD"
unset LD_PRELOAD
export PATH="/sbin:/system/bin:/system/xbin:$PATH"
exec 2>/dev/null
test "$(cat /sys/fs/selinux/enforce)" != 1 && echo "SeLinux is permissive"
test "$(runcon u:r:magisk:s0 echo true)" == "true" && echo "Found Magisk context"
test "$(getprop init.svc.adbd)" != "stopped" && echo "USB Debugging is enabled"
getprop | grep -q "^[init.svc_debug_pid." && echo "Userdebug build is detected!"
cat /proc/mounts | grep -q "magisk" && echo "Found Magisk"
setprop prop.test true && echo "Found props can be changed"
test "$(getprop ro.crypto.state)" != "encrypted" && echo "Data is not encrypted"
mount | grep " /system " | grep -q "^/dev/loop" && echo "Alnormal system partition mounted"
mount | grep " / " | grep -q "^/dev/loop" && echo "Alnormal root partition mounted"

