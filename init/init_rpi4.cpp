/*
* Copyright (C) 2014-2020 The OmniROM Project
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <fstream>
#include <unistd.h>

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/strings.h>

#include "uevent.h"
#include "util.h"

#include <sys/resource.h>
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

namespace android {
namespace init {

using android::base::GetProperty;
using android::base::ReadFileToString;

template <typename T>
static T get(const std::string& path, const T& def) {
    std::ifstream file(path);
    T result;

    file >> result;
    return file.fail() ? def : result;
}

static void property_override(const std::string& name, const std::string& value)
{
    size_t valuelen = value.size();

    prop_info* pi = (prop_info*) __system_property_find(name.c_str());
    if (pi != nullptr) {
        __system_property_update(pi, value.c_str(), valuelen);
    }
    else {
        int rc = __system_property_add(name.c_str(), name.size(), value.c_str(), valuelen);
        if (rc < 0) {
            LOG(ERROR) << "property_set(\"" << name << "\", \"" << value << "\") failed: "
                       << "__system_property_add failed";
        }
    }
}

static void set_revision_property() {
    std::string cpuinfo;
    android::base::ReadFileToString("/proc/cpuinfo", &cpuinfo);

    std::istringstream in(cpuinfo);
    std::string line;
    while (std::getline(in, line)) {
        std::vector<std::string> pieces = android::base::Split(line, ":");
        if (pieces.size() == 2) {
            if (android::base::Trim(pieces[0]) == "Revision") {
                property_override("ro.revision", android::base::Trim(pieces[1]));
                return;
            }
        }
    }
}

/*static void set_audio_card_property() {
    std::string card = android::base::GetProperty("persist.audio.pcm.card", "");
    if (!card.empty()) {
        property_override("audio.pcm.card", card);
    }
}*/

// debug.drm.mode.force=1280x800@60
static void set_drm_mode_property() {
    std::string drmMode = android::base::GetProperty("debug.drm.mode.force", "");
    // security reset - if available always set value from /system/build.prop
    if (!drmMode.empty()) {
        property_override("persist.debug.drm.mode.force", "");
    } else {
        drmMode = android::base::GetProperty("persist.debug.drm.mode.force", "");
        if (!drmMode.empty()) {
            property_override("debug.drm.mode.force", drmMode);
        }
    }
}

// gps.device.path=/dev/ttyACM0
static void set_gps_device_property() {
    std::string gpsDevice = android::base::GetProperty("persist.gps.device.path", "");
    if (!gpsDevice.empty()) {
        property_override("gps.device.path", gpsDevice);
    }
}

void vendor_load_properties()
{
    set_revision_property();
    
    std::string device = "rpi4";
    ImportKernelCmdline([&](const std::string& key, const std::string& value) {
        if (key == "androidboot.rpi4.device") {
            device = value;
        }
    });
    property_override("sys.rpi4.device", device);
    if (device == "cutiepi") {
        // cutiepi has a usb audio solution but we let audio.primary handle it
        property_override("audio.pcm.card", "3");
    }
    // TODO 
    //set_audio_card_property();

    set_drm_mode_property();

    set_gps_device_property();
}

void vendor_create_device_symlinks(int partNum, std::string partName, std::vector<std::string>& links)
{
    LOG(INFO) << "vendor_create_device_symlinks: device " << partName;

    // TODO raspi hardcode start
    if (partNum == 2 || partName.find("sda2") != std::string::npos
                || partName.find("mmcblk0p2") != std::string::npos) {
        links.emplace_back("/dev/block/by-name/system");
    } else if (partNum == 3 || partName.find("sda3") != std::string::npos
                || partName.find("mmcblk0p3") != std::string::npos) {
        links.emplace_back("/dev/block/by-name/vendor");
    } else if (partNum == 4 || partName.find("sda4") != std::string::npos
                || partName.find("mmcblk0p4") != std::string::npos) {
        links.emplace_back("/dev/block/by-name/userdata");
    } else if (partNum == 1 || partName.find("sda1") != std::string::npos
                || partName.find("mmcblk0p1") != std::string::npos) {
        links.emplace_back("/dev/block/by-name/boot");
    }
}
}
}
