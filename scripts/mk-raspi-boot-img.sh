#!/bin/sh

if [ -z $OUT_DIR ]; then
    OUT_DIR=`pwd`/out
fi

IN_IMAGE_DIR=$OUT_DIR/target/product/rpi4/
IN_BOOT_FILES=$ANDROID_BUILD_TOP/vendor/brcm/rpi4/proprietary/boot/
OUT_IMAGE_FILE=$HOME/raspberrypi/boot.img

options=$(getopt -o ho:i:b: -- "$@")
[ $? -eq 0 ] || { 
    echo "Incorrect options provided"
    exit 1
}
eval set -- "$options"
while true; do
    case "$1" in
    -o)
        shift
        OUT_IMAGE_FILE=$1
        shift
        ;;
    -b)
        shift
        IN_BOOT_FILES=$1
        shift
        ;;
    -h)
        echo "-b <boot file dir> -o <image file>"
        echo "e.g. -b $ANDROID_BUILD_TOP/vendor/brcm/rpi4/proprietary/boot/ -o /tmp/omni.img"
        exit 0
        ;;
    --)
        shift
        break
        ;;
    esac
done

if [ -z $OUT_IMAGE_FILE ]; then
    echo "missing -o <image file>"
    exit 0
fi

if [ -z $IN_BOOT_FILES ]; then
    echo "missing -b <boot file dir>"
    exit 0
fi

if  [ ! -f "$IN_IMAGE_DIR/obj/KERNEL_OBJ/arch/arm64/boot/Image" ]; then
    echo "no <input folder>/obj/KERNEL_OBJ/arch/arm64/boot/Image"
    exit 0
fi

if  [ ! -d $IN_BOOT_FILES ]; then
    echo "no <boot file dir>"
    exit 0
fi

if  [ ! -f "$IN_BOOT_FILES/config.txt" ]; then
    echo "no <boot file dir>/config.txt"
    exit 0
fi

echo "create: boot files $IN_BOOT_FILES -> $OUT_IMAGE_FILE"

if [ -f $OUT_IMAGE_FILE ]; then
    rm $OUT_IMAGE_FILE
fi

echo "create empty image"
dd if=/dev/zero of="$OUT_IMAGE_FILE" bs=1M count=128

echo "create partitions"
sudo sfdisk "$OUT_IMAGE_FILE"  << EOF
,,0xC,*
EOF

echo "create file systems"
sudo mkfs.vfat $OUT_IMAGE_FILE -n boot

echo "write boot patition"
sudo mkdir /mnt/tmp
sudo mount $OUT_IMAGE_FILE /mnt/tmp
sudo cp "$IN_IMAGE_DIR/ramdisk.img" /mnt/tmp/
sudo cp "$IN_IMAGE_DIR/obj/KERNEL_OBJ/arch/arm64/boot/Image" /mnt/tmp/Image
sudo cp "$IN_IMAGE_DIR/obj/KERNEL_OBJ/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb" /mnt/tmp/
sudo cp "$IN_IMAGE_DIR/obj/KERNEL_OBJ/arch/arm64/boot/dts/broadcom/bcm2711-rpi-400.dtb" /mnt/tmp/
sudo cp "$IN_IMAGE_DIR/obj/KERNEL_OBJ/arch/arm64/boot/dts/broadcom/bcm2711-rpi-cm4.dtb" /mnt/tmp/
sudo cp "$IN_IMAGE_DIR/obj/KERNEL_OBJ/arch/arm64/boot/dts/broadcom/bcm2711-rpi-cm4s.dtb" /mnt/tmp/
sudo mkdir /mnt/tmp/overlays/
sudo cp $IN_IMAGE_DIR/obj/KERNEL_OBJ/arch/arm64/boot/dts/overlays/* /mnt/tmp/overlays/
sudo cp $IN_BOOT_FILES/* /mnt/tmp/
sync

echo "unmounting"
sudo umount /mnt/tmp
sudo rm -fr /mnt/tmp

exit 1
