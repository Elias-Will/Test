#!/usr/bin/env bash
system_profiler -detailLevel basic SPEthernetDataType | grep "Address" | head -n 1 | awk -F": " '{ print $2 }'