#!/usr/bin/env bash
if [[ "$1" == "-ni" ]]
then
    INTERACTIVE=0
else
    INTERACTIVE=1
fi

if [ $INTERACTIVE -eq 0 ]
then
    echo "Let only one iOS device plugged on the USB port"
    echo "Unlock the phone"
    echo ""
    echo "Press a key to continue."
    read
fi
PAIRED=1
idevicepair validate
PAIRED=$?

while [ $PAIRED -eq 1 ]
do
    echo -e "Device Not Paired. Unlock the iOS Device. \n Trust the computer if asked."
    idevicepair pair
    PAIRED=$?
    sleep 2
done

echo "Getting the info"
ideviceinfo

echo "Paired Status: $PAIRED"

if [ $PAIRED -eq 0 ]
then
    echo "Unpairing ..."
    idevicepair unpair
    PAIRED=$?

    while [ $PAIRED -eq 1 ]
    do
        echo -e "Device STILL Paired. Don't unplug it."
        sleep 5
        idevicepair unpair
        PAIRED=$?
    done

    echo "You can now safely unplug the iOS Device"
fi