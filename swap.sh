#!/bin/bash

source ~/scripts/system/config/env

read -p "file? ("$swapfile")" file
if [ -z $file ]; then file=$swapfile; fi
read -p "size? ("$swapsize")" size
if [ -z $size ]; then size=$swapsize; fi
sudo fallocate -l $size $file;
sudo chmod 600 $file;
sudo mkswap $file;
sudo swapon $file;
