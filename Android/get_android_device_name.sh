#!/usr/bin/env bash
if [ -z "$1" ]
then
    # echo "Device is not set, trying first device"
    DEVICE=$(bash get_first_android_connected_device.sh)
fi
#adb -s $DEVICE shell getprop ro.product.device
MANUFACTURER=$(bash get_android_device_manufacturer.sh)
case $MANUFACTURER in
(*[Ss][Oo][Nn][Yy]*)
#    echo "Sony Ericsson device"
    adb -s $DEVICE shell getprop ro.semc.product.name
    ;;
(*)
    adb -s $DEVICE shell getprop ro.product.name
    ;;
esac
