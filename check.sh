# detect some traces
unset LD_PRELOAD

detect(){
export PATH="/sbin:/system/bin:/system/xbin:$PATH"
exec 2>/dev/null
test "$(cat /sys/fs/selinux/enforce)" == 0 && echo "SELinux is permissive"
test "$(runcon u:r:magisk:s0 echo true)" == "true" && echo "Found Magisk contexts. Do not use SELinux Permissive"
test "$(getprop init.svc.adbd)" != "stopped" && echo "USB Debugging is enabled. Set property init.svc.adbd to \"stopped\" to hide"
getprop | grep -q "^[init.svc_debug_pid." && echo "Userdebug build is detected!"
cat /proc/mounts | grep -q "magisk" && echo "Found Magisk. Use Shamiko to hide."
setprop prop.test true && echo "Any apps can change system properties. Do not use SELinux Permissive"
test "$(getprop ro.crypto.state)" != "encrypted" && echo "Data is not encrypted. Set property ro.crypto.state to \"encrypted\" to hide"
mount | grep " /system " | grep -q "^/dev/loop" && echo "Alnormal system partition mounted (Cannot hide)"
mount | grep " / " | grep -q "^/dev/loop" && echo "Alnormal root partition mounted (Cannot hide)"
{ test -e "/system/addon.d"; } && echo "Device (maybe) is using Custom ROM"
{ test "$(ls -id /data | awk '{ print $1 }')" != "2"; } && echo "Data partition was mounted abnormally"
cat /proc/mounts | grep -q " /proc/cpuinfo " && echo "CPU information is modified"
}

MESSAGE="$(detect)"
echo "Scanning..."
test -z "$MESSAGE" && echo "No suspicious traces were found"
echo "$MESSAGE"
