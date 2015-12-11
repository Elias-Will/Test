#!/usr/bin/env bash
system_profiler -detailLevel full SPHardwareDataType | grep "Core" | awk -F": " '{ print $2 }' | sed 1d | sed '$d'
