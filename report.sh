#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

disk1_use=$(df | grep -E $DISK1 | awk '{print $5}' | sed 's/%//')
disk2_use=$(df | grep -E $DISK2 | awk '{print $5}' | sed 's/%//')
mem_use=$(free | grep Mem | awk '{print $3 / $2 * 100}' | cut -d , -f 1 | awk '{printf "%.0f\n",$1}')
swap_use=$(free | grep Swap | awk '{print $3 / $2 * 100}'| cut -d , -f 1 | awk '{printf "%.0f\n",$1}')
cpu_use=$(top -bn2 | grep '%Cpu' | tail -1 | grep -P '(....|...) id,'| awk '{print 100-$8}' | sed 's/,/./g')
int_ip=$(hostname -I | cut -d' ' -f1)
[ -z $EXT_IP ] && ext_ip=$(curl checkip.amazonaws.com) || ext_ip=$EXT_IP
owner=$OWNER

cpu_type=$(lscpu | grep -a "Model name" | awk -F "Model name:" '{print $2}' | sed 's/^[[:space:]]*//')
mem_size=$(free -h | grep Mem | awk '{print $2}')
swap_size=$(free -h | grep Swap | awk '{print $2}')
cores=$(lscpu | grep "CPU(s):" | head -1 | awk '{print $2}')
info="$cpu_type, $mem_size RAM, $swap_size swap, $cores cores"

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
       "id":"$MACHINE",
       "grp":"machine",
       "owner":"$OWNER"
  },
  "fields": {
      "disk1":"$disk1_use",
      "disk2":"$disk2_use",
      "memory":"$mem_use",
      "swap":"$swap_use",
      "cpu":"$cpu_use",
      "internal ip":"$int_ip",
      "external ip":"$ext_ip",
      "message":"$message",
      "info":"$info"
  }
}
EOF

cat $json
