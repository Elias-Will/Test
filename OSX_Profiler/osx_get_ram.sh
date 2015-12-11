#!/usr/bin/env bash
system_profiler -detailLevel full SPHardwareDataType | grep "Memory" | awk -F": " '{ print $2 }'
system_profiler -detailLevel full SPMemoryDataType | grep "Speed" | awk -F": " '{ print $2 }'
echo "Upgradeable: $(system_profiler -detailLevel full SPMemoryDataType | grep "Upgradeable" | awk -F": " '{ print $2 }')"