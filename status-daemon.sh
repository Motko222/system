#!/bin/bash
source ~/.bash_profile

while true
do
 for i in $STATUS
 do
   bash ~/scripts/$i/report.sh
 done
 sleep 30m
done
