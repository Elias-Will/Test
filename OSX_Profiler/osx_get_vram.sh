#!/usr/bin/env bash
system_profiler -detailLevel full SPDisplaysDataType | grep "VRAM" | grep "Total" | awk -F" " '{ print $3 }' | uniq