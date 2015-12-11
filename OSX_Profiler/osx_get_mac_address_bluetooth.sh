#!/usr/bin/env bash
system_profiler -detailLevel basic SPBluetoothDataType | grep "Address" | head -n 1 | awk -F": " '{ print $2 }'| tr '-' ':'