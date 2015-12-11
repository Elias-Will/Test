#!/usr/bin/env bash
sysctl machdep.cpu.brand_string | awk -F": " '{ print $2 }'