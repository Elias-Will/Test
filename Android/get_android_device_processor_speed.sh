#!/usr/bin/env bash
if [ -z "$1" ]
then
    # echo "Device is not set, trying first device"
    DEVICE=$(bash get_first_android_connected_device.sh)
fi
adb -s $DEVICE shell cat "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq" | awk '{ print $1/1000000 }' | tr ',' '.'
