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
package org.omnirom.device;

import android.content.ContentResolver;
import android.content.Context;
import android.content.res.Resources;
import android.content.Intent;
import android.graphics.Point;
import android.os.Bundle;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.os.SystemProperties;
import androidx.preference.PreferenceFragment;
import androidx.preference.ListPreference;
import androidx.preference.Preference;
import androidx.preference.PreferenceScreen;
import android.provider.Settings;
import android.view.Display;
import android.view.Display.Mode;
import android.view.View;
import android.view.IWindowManager;
import android.view.Surface;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class DeviceSettings extends PreferenceFragment implements
        Preference.OnPreferenceChangeListener {
    private static final String TAG = "DeviceSettings";
    private static final String KEY_ROTATION_LOCK = "rotation_lock";
    private static final String KEY_BOOT_MODE = "boot_mode";
    private static final String KEY_AUDIO_CARD = "audio_card";
    private static final String KEY_CPU_GOVERNOR = "cpu_governor";
    private static final String KEY_CPU_MAX_FREQ = "cpu_max_Freq";

    private static final String BOOT_MODE_PROPERTY = "sys.rpi4.boot_mode";
    private static final String AUDIO_CARD_PROPERTY = "persist.rpi4.audio.pcm.card";
    private static final String AUDIO_OUTPUT_DEVICE_PROPERTY = "persist.rpi4.audio.output.device";
    private static final String CPU_GOVERNOR_PROPERTY = "persist.rpi4.cpufreq.governor";
    private static final String CPU_MAX_FREQ_PROPERTY = "persist.rpi4.cpufreq.max_freq";

    private static final String CPU_SYSFS_GOVERNORS = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors";
    private static final String CPU_SYSFS_GOVERNOR = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor";
    private static final String CPU_SYSFS_FREQUENCIES = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies";
    private static final String CPU_SYSFS_MAX_FREQ = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq";

    private IWindowManager mWindowManager;
    private ListPreference mRotationLock;
    private ListPreference mBootMode;
    private ListPreference mAudioCard;
    private ListPreference mCPUGovernor;
    private ListPreference mCPUMaxFreq;
    // 0 landscape 1 portrait
    private int mNativeOrientation;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.main, rootKey);
        mWindowManager = IWindowManager.Stub.asInterface(
                ServiceManager.getService(Context.WINDOW_SERVICE));
        mRotationLock = (ListPreference) findPreference(KEY_ROTATION_LOCK);
        mRotationLock.setOnPreferenceChangeListener(this);
        mRotationLock.setSummary(mRotationLock.getEntry());

        mBootMode = (ListPreference) findPreference(KEY_BOOT_MODE);
        mBootMode.setOnPreferenceChangeListener(this);
        String bootMode = getBootMode();
        mBootMode.setValue(bootMode);
        mBootMode.setSummary(mBootMode.getEntry());

        mAudioCard = (ListPreference) findPreference(KEY_AUDIO_CARD);
        mAudioCard.setOnPreferenceChangeListener(this);
        String outputDevice = SystemProperties.get(AUDIO_OUTPUT_DEVICE_PROPERTY, "");
        mAudioCard.setValue(outputDevice);
        mAudioCard.setSummary(mAudioCard.getEntry());

        boolean cutiepi = SystemProperties.get("sys.rpi4.device", "").equals("cutiepi");
        boolean cm4 = SystemProperties.get("ro.boot.model", "").equals("cm4");

        if (cutiepi) {
            mAudioCard.setVisible(false);
        } else if (true || cm4) {
            mAudioCard.setEntryValues(R.array.audio_card_values_cm4);
            mAudioCard.setEntries(R.array.audio_card_entries_cm4);
        }

        mCPUGovernor = (ListPreference) findPreference(KEY_CPU_GOVERNOR);
        mCPUGovernor.setOnPreferenceChangeListener(this);
        setupGovernors();
        String governor = Utils.readLine(CPU_SYSFS_GOVERNOR);
        if (governor != null) {
            mCPUGovernor.setValue(governor);
            mCPUGovernor.setSummary(mCPUGovernor.getEntry());
        }

        mCPUMaxFreq = (ListPreference) findPreference(KEY_CPU_MAX_FREQ);
        mCPUMaxFreq.setOnPreferenceChangeListener(this);
        setupMaxFreq();
        String maxFreq = Utils.readLine(CPU_SYSFS_MAX_FREQ);
        if (maxFreq != null) {
            mCPUMaxFreq.setValue(maxFreq);
            mCPUMaxFreq.setSummary(mCPUMaxFreq.getEntry());
        }

        Display.Mode mode = getActivity().getDisplay().getMode();
        mNativeOrientation = mode.getPhysicalWidth() > mode.getPhysicalHeight() ? 0 : 1;
    }

    @Override
    public boolean onPreferenceTreeClick(Preference preference) {
        return super.onPreferenceTreeClick(preference);
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (preference == mRotationLock) {
            String value = (String) newValue;
            int rotationLockValue = Integer.valueOf(value);
            int userRotation = 0;

            try {
                if (rotationLockValue == 0) {
                    mWindowManager.freezeRotation(Surface.ROTATION_0);
                    mWindowManager.setFixedToUserRotation(Display.DEFAULT_DISPLAY, IWindowManager.FIXED_TO_USER_ROTATION_DEFAULT);
                    mWindowManager.thawRotation();
                } else if (rotationLockValue == 1) {
                    userRotation = mNativeOrientation == 0 ? Surface.ROTATION_0 : Surface.ROTATION_90;
                    mWindowManager.freezeRotation(userRotation);
                    mWindowManager.setFixedToUserRotation(Display.DEFAULT_DISPLAY, IWindowManager.FIXED_TO_USER_ROTATION_ENABLED);
                } else if (rotationLockValue == 2) {
                    userRotation = mNativeOrientation == 0 ? Surface.ROTATION_270 : Surface.ROTATION_0;
                    mWindowManager.freezeRotation(userRotation);
                    mWindowManager.setFixedToUserRotation(Display.DEFAULT_DISPLAY, IWindowManager.FIXED_TO_USER_ROTATION_ENABLED);
                } else if (rotationLockValue == 3) {
                    userRotation = mNativeOrientation == 0 ? Surface.ROTATION_90 : Surface.ROTATION_180;
                    mWindowManager.freezeRotation(userRotation);
                    mWindowManager.setFixedToUserRotation(Display.DEFAULT_DISPLAY, IWindowManager.FIXED_TO_USER_ROTATION_ENABLED);
                } else if (rotationLockValue == 4) {
                    userRotation = mNativeOrientation == 0 ? Surface.ROTATION_180 : Surface.ROTATION_270;
                    mWindowManager.freezeRotation(userRotation);
                    mWindowManager.setFixedToUserRotation(Display.DEFAULT_DISPLAY, IWindowManager.FIXED_TO_USER_ROTATION_ENABLED);
                }
                mRotationLock.setSummary(mRotationLock.getEntries()[rotationLockValue]);
            } catch (RemoteException e){
                Log.e(TAG, "freezeRotation", e);
            }
        } else if (preference == mAudioCard) {
            String value = (String) newValue;
            SystemProperties.set(AUDIO_OUTPUT_DEVICE_PROPERTY, value);
            String card = SystemProperties.get(AUDIO_CARD_PROPERTY, "");
            // TODO
            if (!card.equals("1")) {
                SystemProperties.set(AUDIO_CARD_PROPERTY, "1");
            }

            int index = Arrays.asList(mAudioCard.getEntryValues()).indexOf(value);
            mAudioCard.setSummary(mAudioCard.getEntries()[Math.max(0, index)]);
        } else if (preference == mCPUGovernor) {
            String value = (String) newValue;
            SystemProperties.set(CPU_GOVERNOR_PROPERTY, value);
            mCPUGovernor.setSummary(value);
        } else if (preference == mCPUMaxFreq) {
            String value = (String) newValue;
            SystemProperties.set(CPU_MAX_FREQ_PROPERTY, value);
            mCPUMaxFreq.setSummary(value);
        } else if (preference == mBootMode) {
            String value = (String) newValue;
            switchBootMode(value);
            mBootMode.setSummary(mBootMode.getEntries()[mBootMode.findIndexOfValue(value)]);
        }
        return true;
    }

    private void switchBootMode(String mode) {
        SystemProperties.set(BOOT_MODE_PROPERTY, mode);
    }

    private String getBootMode() {
        return SystemProperties.get(BOOT_MODE_PROPERTY);
    }

    private void setupGovernors() {
        List<String> governors = Utils.readLineAsArray(CPU_SYSFS_GOVERNORS);
        if (governors != null) {
            String[] g = governors.toArray(new String[governors.size()]);
            mCPUGovernor.setEntryValues(g);
            mCPUGovernor.setEntries(g);
        } else {
            mCPUGovernor.setEnabled(false);
        }
    }

    private void setupMaxFreq() {
        List<String> frequencies = Utils.readLineAsArray(CPU_SYSFS_FREQUENCIES);
        if (frequencies != null) {
            String[] g = frequencies.toArray(new String[frequencies.size()]);
            mCPUMaxFreq.setEntryValues(g);
            mCPUMaxFreq.setEntries(g);
        } else {
            mCPUMaxFreq.setEnabled(false);
        }
    }
}
