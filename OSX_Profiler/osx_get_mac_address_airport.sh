#!/usr/bin/env bash
system_profiler -detailLevel basic SPAirPortDataType | grep "Address" | head -n 1 | awk -F": " '{ print $2 }'