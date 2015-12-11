#!/usr/bin/env bash
sysctl machdep.cpu.brand_string
system_profiler -detailLevel full SPHardwareDataType | grep "Processor" | awk -F": " '{ print $2 }' | sed -e '$d'
echo "$(system_profiler -detailLevel full SPHardwareDataType | grep "Core" | awk -F": " '{ print $2 }' | sed 1d | sed '$d') Cores"