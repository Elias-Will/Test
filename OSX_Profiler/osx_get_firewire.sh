#!/usr/bin/env bash
system_profiler -detailLevel full SPFireWireDataType | awk -F':' '{ print $2 }' | tr -d '\n'