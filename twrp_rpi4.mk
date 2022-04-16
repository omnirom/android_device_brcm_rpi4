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

TARGET_NO_RECOVERY := false

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

$(call inherit-product, device/brcm/rpi4/device.mk)

PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,$(LOCAL_PATH)/recovery/root,recovery/root)

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/scripts/switch_boot_rom.zip:recovery/root/switch_boot_rom.zip \
    $(DEVICE_PATH)/scripts/fix_quotas.zip:recovery/root/fix_quotas.zip \
    $(DEVICE_PATH)/scripts/resize_userdata.zip:recovery/root/resize_userdata.zip

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := rpi4
PRODUCT_NAME := twrp_rpi4
PRODUCT_BRAND := Raspberry
PRODUCT_MODEL := Pi 4
PRODUCT_MANUFACTURER := Raspberry
