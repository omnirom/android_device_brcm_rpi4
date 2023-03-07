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
    audio.bluetooth.default

# bluetooth firmware
#PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/bluetooth/firmware/BCM4345C0.hcd:vendor/etc/firmware/brcm/BCM4345C0.hcd \
    $(DEVICE_PATH)/bluetooth/firmware/BCM4345C5.hcd:vendor/etc/firmware/brcm/BCM4345C5.hcd

PRODUCT_PROPERTY_OVERRIDES += \
    bluetooth.core.gap.le.privacy.enabled=false \
    bluetooth.profile.asha.central.enabled=true \
    bluetooth.profile.a2dp.source.enabled=true \
    bluetooth.profile.avrcp.target.enabled=true \
    bluetooth.profile.bap.broadcast.assist.enabled=true \
    bluetooth.profile.bap.unicast.client.enabled=true \
    bluetooth.profile.bas.client.enabled=true \
    bluetooth.profile.ccp.server.enabled=true \
    bluetooth.profile.csip.set_coordinator.enabled=true \
    bluetooth.profile.gatt.enabled=true \
    bluetooth.profile.hap.client.enabled=true \
    bluetooth.profile.hfp.ag.enabled=true \
    bluetooth.profile.hid.host.enabled=true \
    bluetooth.profile.mcp.server.enabled=true \
    bluetooth.profile.opp.enabled=true \
    bluetooth.profile.pan.nap.enabled=true \
    bluetooth.profile.pan.panu.enabled=true \
    bluetooth.profile.vcp.controller.enabled=true

PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.audio@7.0-impl \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.soundtrigger@2.3-impl

#PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.2-impl \
    android.hardware.graphics.composer@2.2-service \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    hwcomposer.drm \
    gralloc.gbm

PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@4.0-service.minigbm_gbm_mesa \
    android.hardware.graphics.mapper@4.0-impl.minigbm_gbm_mesa \
    android.hardware.graphics.composer@2.4-impl \
    android.hardware.graphics.composer@2.4-service \
    hwcomposer.drm

# egl
PRODUCT_PACKAGES += \
    libEGL_mesa \
    libGLESv1_CM_mesa \
    libGLESv2_mesa \
    libgallium_dri \
    libglapi

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
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.5-external-service

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml

PRODUCT_PACKAGES += \
    android.hardware.configstore@1.1-service

# gps
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

# PowerHAL
PRODUCT_PACKAGES += \
    android.hardware.power@1.1-impl \
    android.hardware.power@1.1-service.rpi4

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

#PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \

# Wifi
PRODUCT_PACKAGES += libwpa_client wpa_supplicant hostapd wificond wpa_cli

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/wifi/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(DEVICE_PATH)/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(DEVICE_PATH)/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf

# bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.1-service.btlinux \
    btuart

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb@1.1-service

# media configurations
PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/a2dp_in_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_in_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/media/libeffects/data/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml 

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/seccomp_policy/mediaswcodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaswcodec.policy

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/init.vendor.rpi4.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.rpi4.rc \
    $(DEVICE_PATH)/init.rpi4.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.rpi4.usb.rc \
    $(DEVICE_PATH)/fstab.rpi4:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.rpi4 \
    $(DEVICE_PATH)/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc \
    $(DEVICE_PATH)/init.system.rpi4.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.rpi4.rc \
    $(DEVICE_PATH)/fstab.rpi4:$(TARGET_COPY_OUT_RAMDISK)/fstab.rpi4

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/Generic.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Generic.kl

PRODUCT_PACKAGES += \
    audio.primary.rpi4 \
    gps.rpi4

# Light HAL
PRODUCT_PACKAGES += \
    android.hardware.lights-service.rpi4

PRODUCT_PACKAGES += \
    OmniProvision \
    DeviceParts \
    Terminal

ifeq ($(ROM_BUILDTYPE),GAPPS)
PRODUCT_PACKAGES += \
    DeviceRegistration
endif

PRODUCT_PACKAGES += \
    RemovePackages

PRODUCT_PACKAGES += \
    gpiodetect \
    gpiofind \
    gpioget \
    gpioinfo \
    gpiomon \
    gpioset \
    gpiod \
    gpiosetd \
    ttyreader \
    cutoff

PRODUCT_PACKAGES += \
    tinymix \
    tinypcminfo \
    tinyplay \
    tinycap

PRODUCT_PACKAGES += \
    libasound \
    alsa_amixer \
    alsa_aplay \
    alsa_arecord \
    alsa_loop

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/alsa/alsa.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/alsa.conf \
    $(DEVICE_PATH)/alsa/smixer.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/smixer.conf \
    $(DEVICE_PATH)/alsa/cards/vc4-hdmi.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/cards/vc4-hdmi.conf \
    $(DEVICE_PATH)/alsa/cards/aliases.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/cards/aliases.conf \
    $(DEVICE_PATH)/alsa/ctl/default.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/ctl/default.conf \
    $(DEVICE_PATH)/alsa/pcm/side.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/side.conf \
    $(DEVICE_PATH)/alsa/pcm/surround21.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround21.conf \
    $(DEVICE_PATH)/alsa/pcm/surround40.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround40.conf \
    $(DEVICE_PATH)/alsa/pcm/surround41.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround41.conf \
    $(DEVICE_PATH)/alsa/pcm/surround50.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround50.conf \
    $(DEVICE_PATH)/alsa/pcm/surround51.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround51.conf \
    $(DEVICE_PATH)/alsa/pcm/surround71.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround71.conf \
    $(DEVICE_PATH)/alsa/pcm/front.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/front.conf \
    $(DEVICE_PATH)/alsa/pcm/hdmi.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/hdmi.conf \
    $(DEVICE_PATH)/alsa/pcm/iec958.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/iec958.conf \
    $(DEVICE_PATH)/alsa/pcm/modem.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/modem.conf \
    $(DEVICE_PATH)/alsa/pcm/rear.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/rear.conf \
    $(DEVICE_PATH)/alsa/pcm/center_lfe.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/center_lfe.conf \
    $(DEVICE_PATH)/alsa/pcm/default.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/default.conf \
    $(DEVICE_PATH)/alsa/pcm/dmix.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/dmix.conf \
    $(DEVICE_PATH)/alsa/pcm/dpl.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/dpl.conf \
    $(DEVICE_PATH)/alsa/pcm/dsnoop.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/dsnoop.conf

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/scripts/switch_boot.sh:$(TARGET_COPY_OUT_SYSTEM)/xbin/switch_boot

PRODUCT_PACKAGES += \
    fs_config_dirs \
    fs_config_files

PRODUCT_PACKAGES += \
    sensors.iio \
    android.hardware.sensors@1.0-service \
    android.hardware.sensors@1.0-impl

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.relative_humidity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.relative_humidity.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml

# libcamera
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.5-service_64 \
    camera.libcamera \
    ipa_rpi

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/hal/libcamera/camera_hal.yaml:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/camera_hal.yaml \
    $(DEVICE_PATH)/hal/libcamera/ipa/raspberrypi/imx219.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/raspberrypi/imx219.json \
    $(DEVICE_PATH)/hal/libcamera/ipa/raspberrypi/imx219_noir.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/raspberrypi/imx219_noir.json \
    $(DEVICE_PATH)/hal/libcamera/ipa/raspberrypi/imx477.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/raspberrypi/imx477.json \
    $(DEVICE_PATH)/hal/libcamera/ipa/raspberrypi/imx477_noir.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/raspberrypi/imx477_noir.json \
    $(DEVICE_PATH)/hal/libcamera/ipa/raspberrypi/ov5647.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/raspberrypi/ov5647.json \
    $(DEVICE_PATH)/hal/libcamera/ipa/raspberrypi/ov5647_noir.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/raspberrypi/ov5647_noir.json

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml

PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)
PRODUCT_SOONG_NAMESPACES += external/mesa3d
PRODUCT_SOONG_NAMESPACES += packages/apps/Bluetooth
PRODUCT_SOONG_NAMESPACES += hardware/iio-sensors-hal

# for bringup to disable secure adb - copy adbkey.pub from ~/.android
#PRODUCT_ADB_KEYS := device/amlogic/yukawa/adbkey.pub
#PRODUCT_PACKAGES += \
    adb_keys

# Keep the VNDK APEX in /system partition for REL branches as these branches are
# expected to have stable API/ABI surfaces.
#ifneq (REL,$(PLATFORM_VERSION_CODENAME))
  PRODUCT_PACKAGES += com.android.vndk.current.on_vendor
#endif

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

PRODUCT_PACKAGES += \
    androidx.window.extensions \
    androidx.window.sidecar

