#!/usr/bin/env bash
system_profiler -detailLevel full SPPowerDataType | grep "Wattage" | awk -F": " '{ print $2 }' | uniq