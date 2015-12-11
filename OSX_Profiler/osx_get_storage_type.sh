#!/usr/bin/env bash
system_profiler -detailLevel full SPStorageDataType | grep "Medium Type" | awk -F": " '{ print $2 }'