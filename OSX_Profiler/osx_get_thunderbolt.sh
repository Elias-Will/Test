#!/usr/bin/env bash
echo "Number of ports: $(system_profiler -detailLevel full SPThunderboltDataType | grep Port | wc -l)"
system_profiler -detailLevel full SPThunderboltDataType | grep Speed