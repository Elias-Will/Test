#!/usr/bin/env bash
if [ -z "$1" ]
then
    # echo "Device is not set, trying first device"
    DEVICE=$(bash get_first_android_connected_device.sh)
fi

IMEI=$(adb -s $DEVICE shell dumpsys iphonesubinfo | awk -F" = " '/Device ID/ { print $2 }')
echo $IMEI

if [ -z $IMEI ]; then
    IMEI=$(adb -s $DEVICE shell service call iphonesubinfo 1)
    echo $IMEI
    if [ $(echo $IMEI | wc -l) > 2 ]; then
        IMEI="Could not get the IMEI of this device. Must be done manually."
    fi
fi
echo -n $IMEI