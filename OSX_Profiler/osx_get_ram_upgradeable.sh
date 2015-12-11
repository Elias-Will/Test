#!/usr/bin/env bash

system_profiler -detailLevel full SPMemoryDataType | grep "Upgradeable" | awk -F": " '{ print $2 }'