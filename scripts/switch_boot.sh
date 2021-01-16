#!/system/bin/sh
# called from rom
# runs as root!

if [ -u $1 ]; then
    echo "provide argument rom or recovery"
    exit 0
fi

CONFIG_FILE_TARGET=config.txt

if [ $1 == "rom" ]; then
    CONFIG_FILE_SOURCE=config.txt.rom
elif [ $1 == "recovery" ]; then
    CONFIG_FILE_SOURCE=config.txt.twrp
else
    echo "provide argument rom or recovery"
    exit 0
fi

if [ ! -d "/mnt/boot" ]; then
    mkdir /mnt/boot
fi


if [ -b "/dev/block/mmcblk0p1" ]; then
    mount /dev/block/mmcblk0p1 /mnt/boot
    cp /mnt/boot/$CONFIG_FILE_SOURCE /mnt/boot/$CONFIG_FILE_TARGET
    umount /mnt/boot
    #/system/bin/reboot
elif [ -b "/dev/block/sda1" ]; then
    mount /dev/block/sda1 /mnt/boot
    cp /mnt/boot/$CONFIG_FILE_SOURCE /mnt/boot/$CONFIG_FILE_TARGET
    umount /mnt/boot
    #/system/bin/reboot
fi

exit 1