#!/bin/bash

source ~/scripts/system/cfg

read -p "file? ("$SWAPFILE")" file
if [ -z $file ]; then file=$SWAPFILE; fi
read -p "size? ("$SWAPSIZE")" size
if [ -z $size ]; then size=$SWAPSIZE; fi
sudo fallocate -l $size $file;
sudo chmod 600 $file;
sudo mkswap $file;
sudo swapon $file;
