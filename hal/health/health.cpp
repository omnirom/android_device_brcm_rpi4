/*
 * Copyright (C) 2018 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#define LOG_TAG "android.hardware.health@2.1-service.rpi4"

#include <memory>
#include <map>
#include <string_view>

#include <cutils/properties.h>
#include <health/utils.h>
#include <health2impl/Health.h>
#include <utils/Log.h>

using ::android::sp;
using ::android::hardware::Return;
using ::android::hardware::Void;
using ::android::hardware::health::InitHealthdConfig;
using ::android::hardware::health::V1_0::BatteryStatus;
using ::android::hardware::health::V2_0::Result;
using ::android::hardware::health::V2_1::IHealth;
using namespace std::literals;

namespace android {
namespace hardware {
namespace health {
namespace V2_1 {
namespace implementation {

std::map<int, int> batteryLevelMapping = {{3890, 100}, {3880, 95}, {3860, 90}, {3820, 85}, {3800, 80}
  , {3760, 75}, {3730, 70}, {3690, 65}, {3670, 60}, {3650, 55}, {3630, 50}, {3610, 45}, {3600, 40}
    , {3590, 35}, {3560, 30}, {3550, 25}, {3530, 20}, {3510, 15}, {3490, 10}, {3480, 5}, {3000, 0}};


class HealthImpl : public Health {
 public:
  HealthImpl(std::unique_ptr<healthd_config>&& config)
    : Health(std::move(config)) {}

  Return<void> getChargeCounter(getChargeCounter_cb _hidl_cb) override;
  Return<void> getCurrentNow(getCurrentNow_cb _hidl_cb) override;
  Return<void> getCapacity(getCapacity_cb _hidl_cb) override;
  Return<void> getChargeStatus(getChargeStatus_cb _hidl_cb) override;

 protected:
  void UpdateHealthInfo(HealthInfo* health_info) override;
  int calcBatteryLevel(int voltage);
  int getCapacityImpl();
  BatteryStatus getChargeStatusImpl();
};

void HealthImpl::UpdateHealthInfo(HealthInfo* health_info) {
  ALOGI("UpdateHealthInfo");
  auto* battery_props = &health_info->legacy.legacy;
  battery_props->chargerAcOnline = true;
  battery_props->chargerUsbOnline = false;
  battery_props->chargerWirelessOnline = false;
  battery_props->maxChargingCurrent = 500000;
  battery_props->maxChargingVoltage = 5000000;
  battery_props->batteryStatus = getChargeStatusImpl();
  battery_props->batteryHealth = V1_0::BatteryHealth::GOOD;
  battery_props->batteryPresent = getChargeStatusImpl() != BatteryStatus::UNKNOWN;
  battery_props->batteryLevel = getCapacityImpl();
  battery_props->batteryVoltage = 3600;
  battery_props->batteryTemperature = 350;
  battery_props->batteryCurrent = 400000;
  battery_props->batteryCycleCount = 32;
  battery_props->batteryFullCharge = 4000000;
  battery_props->batteryChargeCounter = 1900000;
  battery_props->batteryTechnology = "Li-ion";
}

Return<void> HealthImpl::getChargeCounter(getChargeCounter_cb _hidl_cb) {
  _hidl_cb(Result::SUCCESS, 1900000);
  return Void();
}

Return<void> HealthImpl::getCurrentNow(getCurrentNow_cb _hidl_cb) {
  _hidl_cb(Result::SUCCESS, 400000);
  return Void();
}

Return<void> HealthImpl::getCapacity(getCapacity_cb _hidl_cb) {
  _hidl_cb(Result::SUCCESS, getCapacityImpl());
  return Void();
}

Return<void> HealthImpl::getChargeStatus(getChargeStatus_cb _hidl_cb) {
  _hidl_cb(Result::SUCCESS, getChargeStatusImpl());
  return Void();
}

int HealthImpl::calcBatteryLevel(int voltage) {
  for (auto it = batteryLevelMapping.rbegin(); it != batteryLevelMapping.rend(); ++it) {
    int v = it->first;
    int lvl = it->second;
    ALOGI("calcBatteryLevel %d %d -> %d", voltage, v, lvl);

    if (voltage > v){
      return lvl;
    }
  }
  // should never happen
  return 100;
}

BatteryStatus HealthImpl::getChargeStatusImpl() {
  char property[PROPERTY_VALUE_MAX] = {0};
  int charging = -1;

  if (property_get("sys.rpi4.ttyreader.charge", property, NULL)) {
    charging = strcmp(property, "1") == 0;
  }
  ALOGI("getChargeStatusImpl %d", charging);
  return charging == -1 ? BatteryStatus::UNKNOWN : (charging ? BatteryStatus::CHARGING : BatteryStatus::DISCHARGING);
}

int HealthImpl::getCapacityImpl() {
  char property[PROPERTY_VALUE_MAX] = {0};
  int voltage = -1;
  int charging = -1;

  if (property_get("sys.rpi4.ttyreader.voltage", property, NULL)) {
    voltage = atoi(property);
  }
  
  if (property_get("sys.rpi4.ttyreader.charge", property, NULL)) {
    charging = strcmp(property, "1") == 0;
  }
  int capacity = voltage != -1 ? calcBatteryLevel(voltage) : 100;
  ALOGI("getCapacityImpl %d %d %d", charging, voltage, capacity);

  return charging == -1 ? 100 : (charging ? 100 : capacity == 0 ? 100 : capacity);
}

}  // namespace implementation
}  // namespace V2_1
}  // namespace health
}  // namespace hardware
}  // namespace android


extern "C" IHealth* HIDL_FETCH_IHealth(const char* instance) {
  using ::android::hardware::health::V2_1::implementation::HealthImpl;
  if (instance != "default"sv) {
      return nullptr;
  }
  auto config = std::make_unique<healthd_config>();
  InitHealthdConfig(config.get());

  return new HealthImpl(std::move(config));
}
