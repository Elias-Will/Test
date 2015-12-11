#!/usr/bin/env bash
if [ -z "$1" ]
then
    # echo "Device is not set, trying first device"
    DEVICE=$(bash get_first_android_connected_device.sh)
fi
adb -s $DEVICE shell cat /proc/cpuinfo | head -n 1 | awk -F": " '{ print $2 }'
