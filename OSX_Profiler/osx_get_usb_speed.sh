#!/usr/bin/env bash
system_profiler -detailLevel full SPUSBDataType | grep "USB" | grep "Bus"