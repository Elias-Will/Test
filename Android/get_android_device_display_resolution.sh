#!/usr/bin/env bash
if [ -z "$1" ]
then
    # echo "Device is not set, trying first device"
    DEVICE=$(bash get_first_android_connected_device.sh)
fi
#adb -s $DEVICE shell getprop ro.product.display_resolution | ruby -ne 'puts $_.scan(/[\dp]+ (?=resolution)/)'
RESOLUTION=$(adb -s $DEVICE shell getprop ro.product.display_resolution | ruby -ne 'puts $_.scan(/[\dp]+ (?=resolution)/)')
if [ -z $RESOLUTION ]
then
    RESOLUTION=$(adb -s $DEVICE shell dumpsys window | awk -F"=" '/Display/ { print $5 }' | awk -F" " '/.+/ { print $1 }')
fi
if [ -z $RESOLUTION ]
then
    RESOLUTION=$(adb -s $DEVICE shell dumpsys display | awk 'match ($0,/([0-9 ]+x[0-9 ]+)/) { print substr($0,RSTART,RLENGTH) }' | sort -r -n | head -n 1 | tr -d '\r')
fi
echo -n $RESOLUTION
