#!/usr/bin/env bash
system_profiler -detailLevel full SPDisplaysDataType | grep "Resolution" | awk -F": " '{ print $2 }' | head -n 1 | awk '{ print $1 $2 $3 }'
