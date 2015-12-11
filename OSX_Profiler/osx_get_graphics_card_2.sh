#!/usr/bin/env bash
system_profiler -detailLevel full SPDisplaysDataType | grep Chipset | awk -F": " '{ print $2 }' | head -n 1