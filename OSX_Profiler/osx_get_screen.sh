#!/usr/bin/env bash
system_profiler -detailLevel full SPDisplaysDataType | grep "Display Type" | awk -F": " '{ print $2 }'
system_profiler -detailLevel full SPDisplaysDataType | grep "Resolution" | awk -F": " '{ print $2 }' | uniq
