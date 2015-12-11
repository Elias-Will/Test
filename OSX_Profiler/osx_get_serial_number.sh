#!/usr/bin/env bash
system_profiler -detailLevel full SPHardwareDataType | grep "Serial" | awk -F": " '{ print $2 }'