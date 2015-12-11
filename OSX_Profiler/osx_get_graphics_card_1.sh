#!/usr/bin/env bash
system_profiler -detailLevel full SPDisplaysDataType | grep Chipset | awk -F": " '{ print $2 }' | tail -n 1