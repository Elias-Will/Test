#!/usr/bin/env bash
system_profiler -detailLevel full SPThunderboltDataType | grep Speed | awk -F": " '{ print $2 }' | uniq | tr '\n' ' '