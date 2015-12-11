#!/usr/bin/env bash
system_profiler -detailLevel full SPPowerDataType | grep "Full Charge" | awk -F": " '{ print $2 }' | uniq