#
# Copyright (C) 2020 The OmniROM Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

DEVICE_PATH := device/brcm/rpi4

# Platform
TARGET_BOARD_PLATFORM := bcm2711

TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := false

BOARD_VNDK_VERSION := current
PRODUCT_FULL_TREBLE_OVERRIDE := true

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a72

# Secondary Arch
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

USE_OPENGL_RENDERER := true
TARGET_USES_HWC2 := true
TARGET_USES_64_BIT_BINDER := true

BOARD_MESA3D_USES_MESON_BUILD := true
BOARD_MESA3D_GALLIUM_DRIVERS := v3d vc4
BOARD_MESA3D_VULKAN_DRIVERS := broadcom

# generic wifi
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211

# Kernel
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_SEPARATED_DTBO := false
TARGET_KERNEL_SOURCE := kernel/brcm/arpi
TARGET_KERNEL_CONFIG := ../../../../../../device/brcm/rpi4/kernel/omni_rpi4_510_defconfig
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_ADDITIONAL_FLAGS := DTC_FLAGS="-@"
TARGET_KERNEL_ADDITIONAL_FLAGS += LLVM=1

# Use Gnu AS until we can switch to LLVM_IAS=1
KERNEL_TOOLCHAIN := $(shell pwd)/prebuilts/gas/$(HOST_PREBUILT_TAG)
TARGET_KERNEL_CROSS_COMPILE_PREFIX := aarch64-linux-gnu-
KERNEL_LD := LD=ld.lld

TARGET_COPY_OUT_PRODUCT := system/product
TARGET_COPY_OUT_SYSTEM_EXT := system/system_ext
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2147483648 # 2G
BOARD_VENDORIMAGE_PARTITION_SIZE := 268435456 # 256M
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true
TARGET_USERIMAGES_USE_EXT4 := true

# THIS IS JUST FAKE!!!
# we still only need kernel but with this we can build all with a single make call
BOARD_BOOTIMAGE_PARTITION_SIZE := 43948032
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 43948032
BOARD_USES_FULL_RECOVERY_IMAGE := true

USE_XML_AUDIO_POLICY_CONF := 1
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/hal/gps/manifest.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/hal/sensors/manifest.xml
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.device.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml

BOARD_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy

TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop
TARGET_INIT_VENDOR_LIB := //$(DEVICE_PATH):libinit_rpi4
TARGET_CREATE_DEVICE_SYMLINKS := true

BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_CUSTOM_BT_CONFIG := $(DEVICE_PATH)/bluetooth/vnd_rpi4.txt
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(DEVICE_PATH)/bluetooth/include

BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# libcamera
BOARD_LIBCAMERA_USES_MESON_BUILD := true
BOARD_LIBCAMERA_IPAS := raspberrypi
BOARD_LIBCAMERA_PIPELINES := simple raspberrypi

TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "RGB_565"
TARGET_RECOVERY_FORCE_PIXEL_FORMAT := "RGB_565"
TW_BRIGHTNESS_PATH := "/sys/class/backlight/rpi_backlight/brightness"
TW_EXCLUDE_MTP := true
TW_INCLUDE_CRYPTO := false
TW_INCLUDE_CRYPTO_FBE := false
TW_INCLUDE_FBE_METADATA_DECRYPT := false
TW_NO_BATT_PERCENT := true
TW_NO_REBOOT_BOOTLOADER := true
TW_NO_REBOOT_RECOVERY := true
TW_NO_SCREEN_TIMEOUT := true
TW_THEME := landscape_hdpi
TW_USE_TOOLBOX := true
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
TW_EXTERNAL_STORAGE_PATH := "/usb"
