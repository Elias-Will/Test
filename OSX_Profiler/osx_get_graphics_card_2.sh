#!/usr/bin/env bash
#system_profiler -detailLevel full SPDisplaysDataType | grep Chipset | awk -F": " '{ print $2 }' | head -n 1

VAR=$(system_profiler -detailLevel full SPDisplaysDataType | grep Chipset | awk -F": " '{ print $2 }')
COUNT=$( echo "$VAR" | wc -l )

if [ $COUNT == 1 ]
	then
		exit
	else
		echo $VAR
fi