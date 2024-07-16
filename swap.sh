#!/bin/bash

source ~/.bash_profile
default_file=~/swap1
default_size=8GB

read -p "file? ("$default_file")" file
[ -z $file ] && file=$default_file
read -p "size? ("$default_size")" size
[ -z $size ] && size=$default_size
sudo fallocate -l $size $file
sudo chmod 600 $file
sudo mkswap $file
sudo swapon $file
