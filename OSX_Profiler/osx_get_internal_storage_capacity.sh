#!/usr/bin/env bash
system_profiler -detailLevel full SPStorageDataType | grep "Size" | awk -F": " '{ print $2 }' | uniq | head -n 1 | awk '{ print $1 }' | tr ',' '.'