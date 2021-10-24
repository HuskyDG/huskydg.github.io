
exec 2>/dev/null

# require Magisk busybox
set -o standalone || exit 1

MAGISKTMP="$(magisk --path)"

# Unmount dummy skeletons and MAGISKTMP
MOUNT_LIST="$(for i in /system /vendor /product /system_ext; do
grep "^tmpfs" /proc/mounts | awk '{ print $2 }' | grep ^"$i"
done)"
for hide in $MOUNT_LIST; do
( umount -l "$hide" && echo "Unmounted: $hide" ) &
done
sleep 0.05
[ ! -z "$MAGISKTMP" ] && umount -l "$MAGISKTMP" && echo "unmount: $MAGISKTMP"

# Unmount all Magisk created mounts
MOUNT_LIST="$(grep ".magisk/block" /proc/mounts  | awk '{ print $2 }')"
for hide in $MOUNT_LIST; do
( umount -l "$hide" && echo "Unmounted: $hide" ) &
done
