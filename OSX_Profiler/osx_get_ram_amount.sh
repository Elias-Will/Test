#!/usr/bin/env bash
system_profiler -detailLevel full SPHardwareDataType | grep "Memory" | awk -F" " '{ print $2 }'