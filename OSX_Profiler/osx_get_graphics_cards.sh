#!/usr/bin/env bash
system_profiler -detailLevel full SPDisplaysDataType | grep Chipset | awk -F": " '{ print $2 }'
system_profiler -detailLevel full SPDisplaysDataType | grep "VRAM" | awk -F": " '{ print $2 }' | uniq