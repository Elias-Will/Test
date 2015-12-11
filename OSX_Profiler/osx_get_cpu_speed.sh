#!/usr/bin/env bash
system_profiler -detailLevel full SPHardwareDataType | grep "Processor" | awk -F": " '{ print $2 }' | sed -e '$d' | sed 1d | sed -e 's/,/./' | awk -F' ' '{ print $1 }'
