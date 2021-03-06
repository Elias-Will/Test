#!/usr/bin/env bash
if [ -z "$1" ]
then
    # echo "Device is not set, trying first device"
    DEVICE=$(bash get_first_android_connected_device.sh)
fi
adb -s $DEVICE shell getprop ro.product.display_resolution | ruby -ne 'puts $_.scan(/[\d.]+ (?=inch)/)' | awk '{ print $1 }'
