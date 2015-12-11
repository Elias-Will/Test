#!/usr/bin/env bash
system_profiler -detailLevel full SPMemoryDataType | grep "Speed" | awk -F": " '{ print $2 }' | awk '{ print $1 }' | uniq | grep -v "Empty"