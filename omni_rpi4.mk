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

# Inherit device configuration
DEVICE_PATH := device/brcm/rpi4

PRODUCT_QUOTA_PROJID := 1
PRODUCT_PROPERTY_OVERRIDES += external_storage.projid.enabled=1
PRODUCT_PROPERTY_OVERRIDES += external_storage.sdcardfs.enabled=0

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/overlay

$(call inherit-product, vendor/omni/config/common_tablet.mk)
$(call inherit-product, device/brcm/rpi4/device.mk)

# Boot animation
TARGET_BOOTANIMATION_SIZE := 720p

ALLOW_MISSING_DEPENDENCIES := true

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := rpi4
PRODUCT_NAME := omni_rpi4
PRODUCT_BRAND := Raspberry
PRODUCT_MODEL := Raspberry Pi 4
PRODUCT_MANUFACTURER := Raspberry
PRODUCT_RELEASE_NAME := Raspberry Pi 4

$(call inherit-product, vendor/brcm/rpi4/rpi4-vendor.mk)
