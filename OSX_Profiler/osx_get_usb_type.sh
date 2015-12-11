#!/usr/bin/env bash
USB_3=$(system_profiler -detailLevel full SPUSBDataType | grep "USB 3.0" | wc -l)
if (( $USB_3 > 0 ))
then
    echo "3.0"
else
    echo "2.0"
fi