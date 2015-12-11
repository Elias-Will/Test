#!/usr/bin/env bash
system_profiler -detailLevel full SPStorageDataType | grep "Medium Type" | awk -F": " '{ print $2 }'
system_profiler -detailLevel full osx_get_storage.sh full SPStorageDataType | grep "Size" | awk -F": " '{ print $2 }' | uniq