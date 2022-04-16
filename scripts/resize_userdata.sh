#!/sbin/sh
# called from recovery
# based on resize script from https://konstakang.com/

# detect storage device
if [ -b "/dev/block/mmcblk0" ]; then
DEVICE=mmcblk0
PARTITION=p4
else
DEVICE=sda
PARTITION=4
fi

# unmount partitions
umount /data 2>&1
umount /sdcard 2>&1

# remove existing data partition and create new partition table entry
FIRST_SECTOR=$(/tmp/fdisk -l /dev/block/$DEVICE | grep $DEVICE$PARTITION | awk '{print $2}')
echo FIRST_SECTOR=$FIRST_SECTOR >> /tmp/resize.log

(
echo d
echo 4
echo n
echo p
echo $FIRST_SECTOR
echo
echo n
echo w
) | /tmp/fdisk /dev/block/$DEVICE 1>> /tmp/resize.log 2>&1
EXIT=$?
if [ $EXIT != "0" ]; then
    echo "fdisk " $EXIT >> /tmp/resize.log
    exit $EXIT
fi

sync
sleep 5

# calculate new filesystem size
CURSIZE=$(/tmp/fdisk -l /dev/block/$DEVICE | grep $DEVICE$PARTITION | awk '{print $4}')
NEWSIZE=$(expr \( $CURSIZE \* 512 \) / 4096)
echo $CURSIZE >> /tmp/resize.log
echo $NEWSIZE >> /tmp/resize.log

# resize filesystem
resize2fs -f /dev/block/$DEVICE$PARTITION $NEWSIZE 1>> /tmp/resize.log 2>&1

EXIT=$?
if [ $EXIT != "0" ]; then
    echo "resize2fs " $EXIT >> /tmp/resize.log
    exit $EXIT
fi

# make sure we have project quotas
# resize2fs should retain - but better save then sorry
tune2fs -O project,quota /dev/block/$DEVICE$PARTITION 1>> /tmp/resize.log 2>&1

EXIT=$?
if [ $EXIT != "0" ]; then
    echo "tune2fs " $EXIT >> /tmp/resize.log
    exit $EXIT
fi

# unmount partitions
umount /data 2>&1
umount /sdcard 2>&1

exit 0
