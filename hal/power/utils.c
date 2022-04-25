/*
 * Copyright (C) 2017 The Android Open Source Project
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


#define LOG_TAG "android.hardware.power@1.1-service.rpi4"

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "utils.h"

#include <utils/Log.h>

int sysfs_read(char *path, char *s, int num_bytes)
{
    char buf[80];
    int count;
    int ret = 0;
    int fd = open(path, O_RDONLY);
    if (fd < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error opening %s: %s\n", path, buf);
        return -1;
    }
    if ((count = read(fd, s, num_bytes - 1)) < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error writing to %s: %s\n", path, buf);
        ret = -1;
    } else {
        s[count] = '\0';
    }
    close(fd);
    return ret;
}

int sysfs_write(char *path, char *s)
{
    char buf[80];
    int len;
    int ret = 0;
    int fd = open(path, O_WRONLY);
    if (fd < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error opening %s: %s\n", path, buf);
        return -1 ;
    }
    len = write(fd, s, strlen(s));
    if (len < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error writing to %s: %s\n", path, buf);
        ret = -1;
    }
    close(fd);
    return ret;
}

int get_scaling_governor(char governor[], int size)
{
    if (sysfs_read(SCALING_GOVERNOR_PATH, governor,
                size) == -1) {
        // Can't obtain the scaling governor. Return.
        return -1;
    } else {
        // Strip newline at the end.
        int len = strlen(governor);
        len--;
        while (len >= 0 && (governor[len] == '\n' || governor[len] == '\r'))
            governor[len--] = '\0';
    }
    return 0;
}

int get_scaling_max_freq(char max_freq[], int size)
{
    if (sysfs_read(SCALING_MAX_FREQ, max_freq,
                size) == -1) {
        // Can't obtain the scaling max_freq. Return.
        return -1;
    } else {
        // Strip newline at the end.
        int len = strlen(max_freq);
        len--;
        while (len >= 0 && (max_freq[len] == '\n' || max_freq[len] == '\r'))
            max_freq[len--] = '\0';
    }
    return 0;
}

int get_scaling_min_freq(char min_freq[], int size)
{
    if (sysfs_read(SCALING_MIN_FREQ, min_freq,
                size) == -1) {
        // Can't obtain the scaling min_freq. Return.
        return -1;
    } else {
        // Strip newline at the end.
        int len = strlen(min_freq);
        len--;
        while (len >= 0 && (min_freq[len] == '\n' || min_freq[len] == '\r'))
            min_freq[len--] = '\0';
    }
    return 0;
}

int get_cpuinfo_min_freq(char min_freq[], int size)
{
    if (sysfs_read(CPUINFO_MIN_FREQ, min_freq,
                size) == -1) {
        // Can't obtain the scaling min_freq. Return.
        return -1;
    } else {
        // Strip newline at the end.
        int len = strlen(min_freq);
        len--;
        while (len >= 0 && (min_freq[len] == '\n' || min_freq[len] == '\r'))
            min_freq[len--] = '\0';
    }
    return 0;
}

int get_cpuinfo_max_freq(char max_freq[], int size)
{
    if (sysfs_read(CPUINFO_MAX_FREQ, max_freq,
                size) == -1) {
        // Can't obtain the scaling max_freq. Return.
        return -1;
    } else {
        // Strip newline at the end.
        int len = strlen(max_freq);
        len--;
        while (len >= 0 && (max_freq[len] == '\n' || max_freq[len] == '\r'))
            max_freq[len--] = '\0';
    }
    return 0;
}
