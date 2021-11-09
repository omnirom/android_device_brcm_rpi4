#
# Copyright (C) 2020 The LineageOS Project
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

# Enable Scoped Storage related
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Build default bluetooth a2dp and usb audio HALs
PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio@2.0-impl \
    audio.usb.default \
    audio.primary.yukawa \
    audio.r_submix.default \
    audio.bluetooth.default \
    audio.hearing_aid.default \
    audio.a2dp.default

PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.audio@7.0-impl \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.soundtrigger@2.3-impl

PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.2-impl \
    android.hardware.graphics.composer@2.2-service \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    hwcomposer.drm \
    gralloc.gbm

# egl
PRODUCT_PACKAGES += \
    libGLES_mesa

# Vulkan
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_0_3.xml:vendor/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:vendor/etc/permissions/android.hardware.vulkan.level.xml

PRODUCT_PACKAGES +=  vulkan.broadcom

#PRODUCT_PACKAGES += \
    libEGL_swiftshader \
    libGLESv1_CM_swiftshader \
    libGLESv2_swiftshader

# Software Gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.software

PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.4-service.clearkey

# Enable USB Camera
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-external-service

PRODUCT_PACKAGES += \
    android.hardware.configstore@1.1-service

# gps
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

# PowerHAL
PRODUCT_PACKAGES += \
    android.hardware.power-service.example

# PowerStats HAL
PRODUCT_PACKAGES += \
    android.hardware.power.stats-service.example

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml \
    $(DEVICE_PATH)/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml

#PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \

# Wifi
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    hostapd \
    hostapd_cli \
    wpa_supplicant \
    wpa_cli \
    wpa_supplicant.conf \
    libkeystore-wifi-hidl \
    libkeystore-engine-wifi-hidl

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(DEVICE_PATH)/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf

# bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service.rpi4 \
    btuart

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb@1.1-service

# media configurations
PRODUCT_COPY_FILES += \
    frameworks/av/media/libeffects/data/audio_effects.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.conf \
    frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    $(DEVICE_PATH)/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    $(DEVICE_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

# use default in /apex/com.android.media.swcodec
#PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_tv.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_tv.xml

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/init.vendor.rpi4.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.rpi4.rc \
    $(DEVICE_PATH)/init.rpi4.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.rpi4.usb.rc \
    $(DEVICE_PATH)/fstab.rpi4:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.rpi4 \
    $(DEVICE_PATH)/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc \
    $(DEVICE_PATH)/init.system.rpi4.rc:root/init.rpi4.rc \
    $(DEVICE_PATH)/fstab.rpi4:$(TARGET_COPY_OUT_RAMDISK)/fstab.rpi4

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/Generic.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Generic.kl

PRODUCT_PACKAGES += \
    audio.primary.rpi4 \
    gps.rpi4

PRODUCT_PACKAGES += \
    libinit_rpi4

PRODUCT_PACKAGES += \
    Provision2 \
    DeviceParts \
    Terminal \
    RemoveOpenDelta \
    RemoveCamera2

PRODUCT_PACKAGES += \
    htop \
    zip

PRODUCT_PACKAGES += \
    gpiodetect \
    gpiofind \
    gpioget \
    gpioinfo \
    gpiomon \
    gpioset \
    gpiod \
    gpiosetd

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/scripts/switch_boot.sh:$(TARGET_COPY_OUT_SYSTEM)/xbin/switch_boot

PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)
PRODUCT_SOONG_NAMESPACES += external/mesa3d
PRODUCT_SOONG_NAMESPACES += packages/apps/Bluetooth

# for bringup to disable secure adb - copy adbkey.pub from ~/.android
#PRODUCT_ADB_KEYS := device/amlogic/yukawa/adbkey.pub
#PRODUCT_PACKAGES += \
    adb_keys

# Keep the VNDK APEX in /system partition for REL branches as these branches are
# expected to have stable API/ABI surfaces.
ifneq (REL,$(PLATFORM_VERSION_CODENAME))
  PRODUCT_PACKAGES += com.android.vndk.current.on_vendor
endif

# All VNDK libraries (HAL interfaces, VNDK, VNDK-SP, LL-NDK)
PRODUCT_PACKAGES += vndk_package

# Build and run only ART
PRODUCT_RUNTIMES := runtime_libart_default

PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl-rpi4 \
    android.hardware.health@2.1-service

PRODUCT_PROPERTY_OVERRIDES += ro.surface_flinger.use_color_management=false \
    ro.surface_flinger.has_wide_color_display=false \
    ro.surface_flinger.has_HDR_display=false

# recovery
# enable when building recoveryimage
#PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,$(LOCAL_PATH)/recovery/root,recovery/root)

#PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/scripts/switch_boot_recovery.sh:recovery/root/sbin/switch_boot_recovery \
    $(DEVICE_PATH)/scripts/switch_boot_rom.zip:recovery/root/switch_boot_rom.zip
