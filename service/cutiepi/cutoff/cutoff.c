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
#define LOG_TAG "cutoff"

#include <log/log.h>
#include <stdio.h>
#include <unistd.h>
#include <wiringSerial.h>

#define UART_NODE	"/dev/ttyS0"

int main(int argc, char **argv)
{
    int fd;
    uint8_t payload[7];

    if ((fd = serialOpen(UART_NODE, 115200)) < 0) {
        ALOGE("open serial error  - exiting\n");
        return -1;
    }

    payload[0] = 0x5A;
    payload[1] = 0xA5;
    payload[2] = 5;
    payload[3] = 1;
    payload[4] = 0;
    payload[5] = 0xF7;

    // CRC
    payload[6] = 0;
    for (int i = 0; i < 6; i++) {
        payload[6] = (payload[6] + payload[i]);
    }
    // write to UART 
    write(fd, payload, 7) ;
    serialFlush(fd);
    serialClose(fd);
    return 0;
}
