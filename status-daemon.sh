#!/bin/bash

while true
do
 source ~/.bash_profile
 for i in $STATUS
 do
   bash ~/scripts/$i/report.sh
 done
 sleep 30m
done
