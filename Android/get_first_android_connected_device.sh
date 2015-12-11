#!/usr/bin/env bash
adb devices -l | sed -e 1d | awk '{ print $1 }'