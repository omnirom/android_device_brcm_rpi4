/*
* Copyright (C) 2022 The OmniROM Project
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
#define LOG_TAG "ttyreader"

#include <log/log.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <wiringSerial.h>
#include <cutils/properties.h>

#define UART_NODE	"/dev/ttyS0"

static int mVoltageHistory[] = {0,0,0,0,0,0,0,0,0,0};

static int calcMedianVoltage() {
	int sum = 0;
	int values = 0;
	for (int i = 0; i < 10; i++) {
		if (mVoltageHistory[i] != 0) {
			sum += mVoltageHistory[i];
			values++;
		}
	}
	//ALOGD("[BAT] %d %d %d\n", values, sum, sum / values);
	return sum / values;
}

int main(int argc, char **argv)
{
	int fd;
	int charpos, payload_len;
	char gchar = 0;
	int mCmd = 0;
	int mVoltage;
	int mChargeStatus;
	int mKeyType;
	int mChecksum = 0;
	long mData = 0;
	int mDataBytes = 0;
	int mCheckCount = 0;
	int mIsValidated = 0;
	int mVoltageHistoryIndex = 0;

	if ((fd = serialOpen(UART_NODE, 115200)) < 0) {
		ALOGE("open serial error  - exiting\n");
		return -1;
	}
	while (1) {
		int recv_count = serialDataAvail(fd);
		if (recv_count > 0) {
			for (int i = 0; i < recv_count; i++) {
				gchar = serialGetchar(fd);
				//printf("%02x ", gchar);
				if (0x5A == gchar) {
					charpos = 1;
					mChecksum = 0;
					mChecksum += gchar;
				} else if (0xA5 == gchar && charpos == 1) {
					//printf("\n[IPC] ");
					charpos = 2;
					mChecksum += gchar;
				} else if (charpos == 2) {
					mCmd = gchar;
					mChecksum += gchar;
					charpos = 3;
				} else if (charpos == 3) {
					payload_len = gchar;
					mChecksum += gchar;
					charpos = 4;
				} else if (charpos == 4) {
					payload_len =
					    (gchar << 8) + payload_len;
					mData = 0;
					mDataBytes = 0;
					mChecksum += gchar;
					charpos = 5;
				} else if (charpos == 5) {
					mChecksum += gchar;
					payload_len--;

					if (mCmd != 4)
						mData += (gchar << mDataBytes * 8);
					mDataBytes++;
					
					if (payload_len == 0)
						charpos = 6;
				} else if (charpos == 6) {
					if (gchar == (255 & mChecksum)) {
						mIsValidated = 1;
						if (mCmd == 0x01) {
							mKeyType = mData;
							//ALOGD("[KEY] %d\n", mKeyType);
							property_set("sys.rpi4.ttyreader.key", "26");
						}
						if (mCmd == 0x02) {
							int voltage = mData;
							mVoltageHistory[mVoltageHistoryIndex] = voltage;
							if (mVoltageHistoryIndex == 9) {
								mVoltageHistoryIndex = 0;
							} else {
								mVoltageHistoryIndex++;
							}
							mVoltage = calcMedianVoltage();
							//ALOGD("[BAT] %d\n", mVoltage);
							char buf[PROPERTY_VALUE_MAX] = "";
							sprintf(buf, "%d", mVoltage);
							property_set("sys.rpi4.ttyreader.voltage", buf);
						}
						if (mCmd == 0x03) {
							mChargeStatus = mData == 0x04 ? 1 : 0;
							//ALOGD("[CHG] %d\n", mChargeStatus);
							property_set("sys.rpi4.ttyreader.charge", mChargeStatus ? "1" : "0");
						}
					}
					charpos = 0;
					mChecksum = 0;
					payload_len = 0;
				}
			}
			serialFlush(fd);
		} else {
			if (!mIsValidated) {
				mCheckCount++;
			}
			if (mCheckCount > 20 && !mIsValidated) {
				ALOGD("validate check failed - exiting\n");
				return -1;
			}
			// sleep
			usleep (500000) ;	// 500ms
		}
	}

	serialClose(fd);
	return 0;
}
