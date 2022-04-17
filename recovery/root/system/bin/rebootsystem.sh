#!/sbin/sh
# called from recovery

CONFIG_FILE_SOURCE=config.txt.rom
CONFIG_FILE_TARGET=config.txt

echo "will switch to rom boot"

if [ -b "/dev/block/mmcblk0p1" ]; then
    mount /dev/block/mmcblk0p1 /boot
    cp /boot/$CONFIG_FILE_SOURCE /boot/$CONFIG_FILE_TARGET
    umount /boot
elif [ -b "/dev/block/sda1" ]; then
    mount /dev/block/sda1 /boot
    cp /boot/$CONFIG_FILE_SOURCE /boot/$CONFIG_FILE_TARGET
    umount /boot
fi