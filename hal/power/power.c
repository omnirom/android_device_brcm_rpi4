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
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <utils/Log.h>
#include <cutils/properties.h>

#include <hardware/hardware.h>
#include <hardware/power.h>

#include "utils.h"

#define UNUSED_ARGUMENT __attribute((unused))

// in seconds
#define PERFORMANCE_BOOT_TIMEOUT 2

static pthread_t tid = -1;
static char min_freq[1024];
static char max_freq[1024];
static int DEBUG = 1;
static pthread_mutex_t lock;
static char interactive_max_freq[1024];

static void *performance_boost_thread(UNUSED_ARGUMENT void *data)
{
    get_scaling_max_freq(max_freq, 1024);
    get_scaling_min_freq(min_freq, 1024);

    if (!strcmp(min_freq, max_freq)) {
        tid = -1;
        return NULL;
    }
    if (DEBUG) ALOGD("performance_boost start %s -> %s", min_freq, max_freq);

    sysfs_write(SCALING_MIN_FREQ, max_freq);
    sleep(PERFORMANCE_BOOT_TIMEOUT);
    sysfs_write(SCALING_MIN_FREQ, min_freq);

    if (DEBUG) ALOGD("performance_boost end %s -> %s", max_freq, min_freq);

    tid = -1;
    return NULL;
}

static int start_performance_boost()
{
    if (tid != -1) {
        return 0;
    }

    return pthread_create(&tid, NULL, performance_boost_thread, NULL);
}

void power_init(void)
{
    pthread_mutex_init(&lock, NULL);
}

void power_hint(power_hint_t hint, UNUSED_ARGUMENT void *data)
{
    pthread_mutex_lock(&lock);
    if (DEBUG) ALOGD("power_hint hint %d", hint);

    switch (hint) {
     case POWER_HINT_INTERACTION:
        start_performance_boost();
        break;

    case POWER_HINT_VSYNC:
        break;

    case POWER_HINT_LOW_POWER:
        break;

    default:
        break;
    }
    pthread_mutex_unlock(&lock);
}

void set_interactive(bool interactive)  {
    char *end;
    pthread_mutex_lock(&lock);
    if (DEBUG) ALOGD("set_interactive %d", interactive);

    if (interactive) {
        // set to value of persist.rpi4.cpufreq.max_freq
        get_cpuinfo_max_freq(max_freq, 1024);
        int max_freq_int = strtoul(max_freq, &end, 10);
        max_freq_int = property_get_int32("persist.rpi4.cpufreq.max_freq", max_freq_int);
        sprintf(max_freq, "%d", max_freq_int);
        sysfs_write(SCALING_MAX_FREQ, max_freq);
        if (DEBUG) ALOGD("set_interactive scaling_max = %s", max_freq);
    } else {
        get_scaling_max_freq(interactive_max_freq, 1024);
        get_cpuinfo_min_freq(min_freq, 1024);
        sysfs_write(SCALING_MAX_FREQ, min_freq);
        if (DEBUG) ALOGD("set_interactive scaling_max = %s", min_freq);
    }
    pthread_mutex_unlock(&lock);
}
