#!/usr/bin/env bash
if [ -z "$1" ]
then
    # echo "Device is not set, trying first device"
    DEVICE=$(bash get_first_android_connected_device.sh)
fi

SETTINGS_CHECK="adb -s $DEVICE shell if [ -f /system/bin/settings ]; then echo OK; else echo KO; fi"
HAS_SETTINGS=$(eval $SETTINGS_CHECK 2>/dev/null)

if [[ "$HAS_SETTINGS" == "OK" ]]
then
    ADDRESS=$(adb -s $DEVICE shell settings get secure bluetooth_address)
fi

if [ -z "$ADDRESS" ]
then
#    echo "Using alternative method 1"
    ADDRESS=$(adb -s $DEVICE shell dumpsys bluetooth | awk -F" = " '/Local address/ { print $2 }')
fi

if [ -z "$ADDRESS" ]
then
    # ADDRESS_FILE=$(adb -s $DEVICE shell getprop | awk -F": " '/bluetooth/ { print gensub(/\[(.*)\]/,"\\1","g",$2) }')
    # echo $ADDRESS_FILE
    # if [ ! -z "$ADDRESS_FILE" ]
    # then
        ANDROID_COMMAND="adb -s $DEVICE shell cat $ADDRESS_FILE"
        ### HARDCODED
        ADDRESS=$(adb -s $DEVICE shell cat /efs/bluetooth/bt_addr)
#        ADDRESS=$(adb shell cat echo $ADDRESS_FILE)
        ### /HARDCODED
        if [[ $ADDRESS == *"denied"* ]]
        then
            ADDRESS=""
        fi
   #  fi
fi

echo -n $ADDRESS