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

#include <map>
#include <memory>
#include <string_view>

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android/hardware/health/1.0/types.h>
#include <android/hardware/health/2.0/IHealthInfoCallback.h>
#include <android/hardware/health/2.0/types.h>
#include <android/hardware/health/2.1/IHealth.h>
#include <android/hardware/health/2.1/IHealthInfoCallback.h>
#include <hal_conversion.h>

#include <cutils/properties.h>
#include <health/utils.h>

#include <utils/Log.h>

using android::hardware::health::V1_0::BatteryStatus;
using android::hardware::health::V1_0::toString;
using android::hardware::health::V1_0::hal_conversion::convertFromHealthInfo;
using android::hardware::health::V1_0::hal_conversion::convertToHealthConfig;
using android::hardware::health::V1_0::hal_conversion::convertToHealthInfo;
using android::hardware::health::V2_0::Result;
using android::hardware::health::V2_1::IHealth;
using android::hardware::health::V2_1::HealthInfo;

using ScreenOn = decltype(healthd_config::screen_on);

using namespace std::literals;

namespace android {
namespace hardware {
namespace health {
namespace V2_1 {
namespace implementation {

std::map<int, int> batteryLevelMapping = {
    {3890, 100}, {3880, 95}, {3860, 90}, {3820, 85}, {3800, 80}, {3760, 75},
    {3730, 70},  {3690, 65}, {3670, 60}, {3650, 55}, {3630, 50}, {3610, 45},
    {3600, 40},  {3590, 35}, {3560, 30}, {3550, 25}, {3530, 20}, {3510, 15},
    {3490, 10},  {3480, 5},  {3000, 1}};

// Periodic chores fast interval in seconds
#define DEFAULT_PERIODIC_CHORES_INTERVAL_FAST (30 * 1)
#define DEFAULT_PERIODIC_CHORES_INTERVAL_SLOW (60 * 10)

void InitHealthdConfig(struct healthd_config *healthd_config) {
  *healthd_config = {
      .periodic_chores_interval_fast = DEFAULT_PERIODIC_CHORES_INTERVAL_FAST,
      .periodic_chores_interval_slow = DEFAULT_PERIODIC_CHORES_INTERVAL_FAST,
      .energyCounter = NULL,
      .boot_min_cap = 0,
      .screen_on = NULL,
  };
}
class HealthImpl : public IHealth {
public:
  HealthImpl(std::unique_ptr<healthd_config> &&config)
      : healthd_config_(std::move(config)) {
    ALOGI("HealthImpl::HealthImpl");
  }
  // Methods from ::android::hardware::health::V2_0::IHealth follow.
  Return<::android::hardware::health::V2_0::Result> registerCallback(
      const sp<::android::hardware::health::V2_0::IHealthInfoCallback>
          &callback) override;
  Return<::android::hardware::health::V2_0::Result> unregisterCallback(
      const sp<::android::hardware::health::V2_0::IHealthInfoCallback>
          &callback) override;
  Return<::android::hardware::health::V2_0::Result> update() override;
  Return<void> getChargeCounter(getChargeCounter_cb _hidl_cb) override;
  Return<void> getCurrentNow(getCurrentNow_cb _hidl_cb) override;
  Return<void> getCurrentAverage(getCurrentAverage_cb _hidl_cb) override;
  Return<void> getCapacity(getCapacity_cb _hidl_cb) override;
  Return<void> getEnergyCounter(getEnergyCounter_cb _hidl_cb) override;
  Return<void> getChargeStatus(getChargeStatus_cb _hidl_cb) override;
  Return<void> getStorageInfo(getStorageInfo_cb _hidl_cb) override;
  Return<void> getDiskStats(getDiskStats_cb _hidl_cb) override;
  Return<void> getHealthInfo(getHealthInfo_cb _hidl_cb) override;

  // Methods from ::android::hardware::health::V2_1::IHealth follow.
  Return<void> getHealthConfig(getHealthConfig_cb _hidl_cb) override;
  Return<void> getHealthInfo_2_1(getHealthInfo_2_1_cb _hidl_cb) override;
  Return<void> shouldKeepScreenOn(shouldKeepScreenOn_cb _hidl_cb) override;

  // Methods from ::android::hidl::base::V1_0::IBase follow.
  Return<void> debug(const hidl_handle &fd,
                     const hidl_vec<hidl_string> &args) override;

protected:
  void UpdateHealthInfo(HealthInfo *health_info);
  int calcBatteryLevel(int voltage);
  int getCapacityImpl();
  BatteryStatus getChargeStatusImpl();
  int mLastCapacity = 100;
  int mLastVoltage = -1;
  bool isBatteryDevice();
  static const bool DEBUG = false;

private:
  std::unique_ptr<healthd_config> healthd_config_;
};

//
// Callbacks are not supported by the passthrough implementation.
//

Return<Result>
HealthImpl::registerCallback(const sp<V2_0::IHealthInfoCallback> &) {
  return Result::NOT_SUPPORTED;
}
Return<Result>
HealthImpl::unregisterCallback(const sp<V2_0::IHealthInfoCallback> &) {
  return Result::NOT_SUPPORTED;
}

Return<Result> HealthImpl::update() {
  LOG(WARNING) << "HealthImpl::update";

  Result result = Result::UNKNOWN;
  getHealthInfo_2_1([&](auto res, const auto &health_info) {
    result = res;
    if (res != Result::SUCCESS) {
      LOG(ERROR) << "Cannot call getHealthInfo_2_1: " << toString(res);
      return;
    }
  });
  return result;
}

void HealthImpl::UpdateHealthInfo(HealthInfo *health_info) {
  if (DEBUG) ALOGI("UpdateHealthInfo");
  auto *battery_props = &health_info->legacy.legacy;
  if (!isBatteryDevice()) {
    battery_props->batteryPresent = false;
    battery_props->batteryStatus = BatteryStatus::UNKNOWN;
  } else {
    battery_props->chargerAcOnline =
        getChargeStatusImpl() == BatteryStatus::CHARGING;
    battery_props->chargerUsbOnline = false;
    battery_props->chargerWirelessOnline = false;
    battery_props->maxChargingCurrent = 500000;
    battery_props->maxChargingVoltage = 5000000;
    battery_props->batteryStatus = getChargeStatusImpl();
    battery_props->batteryHealth = V1_0::BatteryHealth::GOOD;
    battery_props->batteryPresent =
        getChargeStatusImpl() != BatteryStatus::UNKNOWN;
    battery_props->batteryLevel = getCapacityImpl();
    battery_props->batteryVoltage = mLastVoltage;
    battery_props->batteryTemperature = 350;
    battery_props->batteryCurrent = 400000;
    battery_props->batteryCycleCount = 32;
    battery_props->batteryFullCharge = 4000000;
    battery_props->batteryChargeCounter = 1900000;
    battery_props->batteryTechnology = "Li-ion";
  }
}

Return<void> HealthImpl::getChargeCounter(getChargeCounter_cb _hidl_cb) {
  _hidl_cb(Result::SUCCESS, 1900000);
  return Void();
}

Return<void> HealthImpl::getCurrentNow(getCurrentNow_cb _hidl_cb) {
  _hidl_cb(Result::SUCCESS, 400000);
  return Void();
}

Return<void> HealthImpl::getCurrentAverage(getCurrentAverage_cb _hidl_cb) {
  _hidl_cb(Result::SUCCESS, 400000);
  return Void();
}

Return<void> HealthImpl::getEnergyCounter(getEnergyCounter_cb _hidl_cb) {
  _hidl_cb(Result::SUCCESS, 1900000);
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
  for (auto it = batteryLevelMapping.rbegin(); it != batteryLevelMapping.rend();
       ++it) {
    int v = it->first;
    int lvl = it->second;
    if (voltage > v) {
      return lvl;
    }
  }
  // should never happen
  return -1;
}

BatteryStatus HealthImpl::getChargeStatusImpl() {
  char property[PROPERTY_VALUE_MAX] = {0};
  int charging = -1;

  if (property_get("sys.rpi4.ttyreader.charge", property, NULL)) {
    charging = strcmp(property, "1") == 0;
  }
  if (DEBUG) ALOGI("getChargeStatusImpl %d", charging);
  return charging == -1 ? BatteryStatus::UNKNOWN
                        : (charging ? BatteryStatus::CHARGING
                                    : BatteryStatus::DISCHARGING);
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
  int capacity = voltage != -1 ? calcBatteryLevel(voltage) : -1;
  if (capacity != -1) {
    if (!charging && capacity > mLastCapacity) {
      // it can never get higher if we are not charging
      capacity = mLastCapacity;
    }
    mLastCapacity = capacity;
    mLastVoltage = voltage;
  }
  if (DEBUG) ALOGI("getCapacityImpl %d %d %d", charging, voltage, capacity);

  return charging == -1 ? 100 : (charging ? 99 : capacity == -1 ? 100 : capacity);
}

bool HealthImpl::isBatteryDevice() {
  char property[PROPERTY_VALUE_MAX] = {0};
  int ttyreaderValid = -1;

  if (property_get("sys.rpi4.ttyreader.valid", property, NULL)) {
    ttyreaderValid = strcmp(property, "1") == 0;
    if (!ttyreaderValid) {
      property_set("sys.health.healthloop.disable", "1");
      if (DEBUG) ALOGI("stop healthloop");
    } else {
      if (DEBUG) ALOGI("isBatteryDevice validated");
    }
  }
  if (DEBUG) ALOGI("isBatteryDevice %d", ttyreaderValid);
  return ttyreaderValid;
}

Return<void> HealthImpl::getStorageInfo(getStorageInfo_cb _hidl_cb) {
  // This implementation does not support StorageInfo. An implementation may
  // extend this class and override this function to support storage info.
  _hidl_cb(Result::NOT_SUPPORTED, {});
  return Void();
}

Return<void> HealthImpl::getDiskStats(getDiskStats_cb _hidl_cb) {
  // This implementation does not support DiskStats. An implementation may
  // extend this class and override this function to support disk stats.
  _hidl_cb(Result::NOT_SUPPORTED, {});
  return Void();
}

template <typename T, typename Method>
static inline void GetHealthInfoField(HealthImpl *service, Method func,
                                      T *out) {
  *out = T{};
  std::invoke(func, service, [out](Result result, const T &value) {
    if (result == Result::SUCCESS)
      *out = value;
  });
}

Return<void> HealthImpl::getHealthInfo(getHealthInfo_cb _hidl_cb) {
  return getHealthInfo_2_1([&](auto res, const auto &health_info) {
    _hidl_cb(res, health_info.legacy);
  });
}

Return<void> HealthImpl::getHealthInfo_2_1(getHealthInfo_2_1_cb _hidl_cb) {
  HealthInfo health_info = HealthInfo();

  // Fill in storage infos; these aren't retrieved by BatteryMonitor.
  GetHealthInfoField(this, &HealthImpl::getStorageInfo,
                     &health_info.legacy.storageInfos);
  GetHealthInfoField(this, &HealthImpl::getDiskStats,
                     &health_info.legacy.diskStats);

  // A subclass may want to update health info struct before returning it.
  UpdateHealthInfo(&health_info);

  _hidl_cb(Result::SUCCESS, health_info);
  return Void();
}

Return<void> HealthImpl::debug(const hidl_handle &handle,
                               const hidl_vec<hidl_string> &) {
  if (handle == nullptr || handle->numFds == 0) {
    return Void();
  }

  int fd = handle->data[0];
  getHealthInfo_2_1([fd](auto res, const auto &info) {
    android::base::WriteStringToFd("\ngetHealthInfo -> ", fd);
    if (res == Result::SUCCESS) {
      android::base::WriteStringToFd(toString(info), fd);
    } else {
      android::base::WriteStringToFd(toString(res), fd);
    }
    android::base::WriteStringToFd("\n", fd);
  });

  fsync(fd);
  return Void();
}

Return<void> HealthImpl::getHealthConfig(getHealthConfig_cb _hidl_cb) {
  HealthConfig config = {};
  convertToHealthConfig(healthd_config_.get(), config.battery);
  config.bootMinCap = static_cast<int32_t>(healthd_config_->boot_min_cap);

  _hidl_cb(Result::SUCCESS, config);
  return Void();
}

Return<void> HealthImpl::shouldKeepScreenOn(shouldKeepScreenOn_cb _hidl_cb) {
  if (!healthd_config_->screen_on) {
    _hidl_cb(Result::NOT_SUPPORTED, true);
    return Void();
  }

  Result returned_result = Result::UNKNOWN;
  bool screen_on = true;
  getHealthInfo_2_1([&](auto res, const auto &health_info) {
    returned_result = res;
    if (returned_result != Result::SUCCESS)
      return;
    struct BatteryProperties props = {};
    V1_0::hal_conversion::convertFromHealthInfo(health_info.legacy.legacy,
                                                &props);
    screen_on = healthd_config_->screen_on(&props);
  });
  _hidl_cb(returned_result, screen_on);
  return Void();
}

} // namespace implementation
} // namespace V2_1
} // namespace health
} // namespace hardware
} // namespace android

extern "C" IHealth *HIDL_FETCH_IHealth(const char *instance) {
  using ::android::hardware::health::V2_1::implementation::HealthImpl;
  if (instance != "default"sv) {
    return nullptr;
  }
  auto config = std::make_unique<healthd_config>();
  android::hardware::health::V2_1::implementation::InitHealthdConfig(
      config.get());

  return new HealthImpl(std::move(config));
}
