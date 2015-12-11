#!/usr/bin/env bash
system_profiler -detailLevel full SPThunderboltDataType | grep Port | wc -l | tr -d [:space:]