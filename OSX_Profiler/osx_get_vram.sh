#!/usr/bin/env bash

VRAM=$(system_profiler -detailLevel full SPDisplaysDataType | grep "VRAM" | grep "Total" | awk -F" " '{ print $3 }' | uniq)

if [ -z $VRAM ] 
	then 
		VRAM=$(system_profiler -detailLevel full SPDisplaysDataType | grep "VRAM" | awk -F" " '{ print $4 }' | uniq)
fi

echo $VRAM

#system_profiler -detailLevel full SPDisplaysDataType | grep "VRAM" | grep "Total" | awk -F" " '{ print $3 }' | uniq