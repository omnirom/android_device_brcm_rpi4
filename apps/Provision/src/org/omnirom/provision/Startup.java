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
package org.omnirom.provision;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.provider.DeviceConfig;
import android.provider.Settings;
import android.util.Log;

public class Startup extends BroadcastReceiver {
    private static final String TAG = "OmniProvision";

    @Override
    public void onReceive(final Context context, final Intent bootintent) {
        Log.d(TAG, "onReceive: Startup");

        // set useful defaults
        Settings.Secure.putInt(context.getContentResolver(), "qs_show_brightness", 0);
        DeviceConfig.setProperty(DeviceConfig.NAMESPACE_INTERACTION_JANK_MONITOR, "enabled", "false", true);

        // we dont need the boot receiver anymore
        PackageManager pm = context.getPackageManager();
        ComponentName name = new ComponentName(context, Startup.class);
        pm.setComponentEnabledSetting(name, PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP);
    }
}
