#!/usr/bin/env bash

WAITING_FOR_DEVICE="ADB is now wating for a device ..."
DEVICE_CONNECTED="Android device found."

echo $WAITING_FOR_DEVICE
adb wait-for-device
echo $DEVICE_CONNECTED
