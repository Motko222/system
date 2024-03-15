#!/bin/bash

while true
do
 source ~/.bash_profile
 for i in $STATUS
 do
   folder=$(echo $i | awk -F '--' '{print $1}')
   parameter=$(echo $i | awk -F '--' '{print $2}')
   bash ~/scripts/$folder/report.sh $parameter
 done
 sleep 30m
done
