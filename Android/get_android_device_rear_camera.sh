#!/usr/bin/env bash
if [ -z "$1" ]
then
    # echo "Device is not set, trying first device"
    DEVICE=$(bash get_first_android_connected_device.sh)
fi
CAMERA=$(adb -s $DEVICE shell getprop ro.product.main_camera | tr -d '\r')
#if [ -z $CAMERA ]
#then
##    echo "Alternate Camera info"
#    CAMERA=$(adb -s $DEVICE shell getprop | awk -F": " '/camera/ { print gensub(/\[(.*)\]/,"\\1","g",$2); }' | tr -d '\r')
#fi
echo -n $CAMERA