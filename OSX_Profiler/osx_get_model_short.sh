#!/usr/bin/env bash
system_profiler -detailLevel full SPHardwareDataType | grep "Model" | awk -F": " '{ print $2 }' | tail -n 1 | tr ',' '.'