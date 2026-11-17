#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

disk1_use=$(df | grep -E $DISK1 | awk '{print $5}' | sed 's/%//')
[ $DISK2 ] && disk2_use=$(df | grep -E $DISK2 | awk '{print $5}' | sed 's/%//')
[ $DISK3 ] && disk3_use=$(df | grep -E $DISK3 | awk '{print $5}' | sed 's/%//')
mem_use=$(free | grep Mem | awk '{print $3 / $2 * 100}' | cut -d , -f 1 | awk '{printf "%.0f\n",$1}')
swap_use=$(free | grep Swap | awk '{print $3 / $2 * 100}'| cut -d , -f 1 | awk '{printf "%.0f\n",$1}')
cores=$(nproc)
# real CPU utilisation over 1s from /proc/stat (100 - idle%, iowait counted as idle); load average overstates it on disk-heavy hosts
read -r _ u1 n1 s1 i1 w1 q1 sq1 st1 _ < /proc/stat; sleep 1
read -r _ u2 n2 s2 i2 w2 q2 sq2 st2 _ < /proc/stat
idle=$(( (i2+w2) - (i1+w1) )); total=$(( (u2+n2+s2+i2+w2+q2+sq2+st2) - (u1+n1+s1+i1+w1+q1+sq1+st1) ))
cpu_use=$(( total > 0 ? (100 * (total - idle) + total/2) / total : 0 ))
int_ip=$(hostname -I | cut -d' ' -f1)
[ -z $EXT_IP ] && ext_ip=$(curl -s checkip.amazonaws.com) || ext_ip=$EXT_IP
owner=$OWNER

cpu_type=$(lscpu | grep -a "Model name" | awk -F "Model name:" '{print $2}' | sed 's/^[[:space:]]*//')
mem_size=$(free -h | grep Mem | awk '{print $2}')
swap_size=$(free -h | grep Swap | awk '{print $2}')
cores=$(lscpu | grep "CPU(s):" | head -1 | awk '{print $2}')
info="$cpu_type, $mem_size RAM, $swap_size swap, $cores cores"

status="ok"
[ $disk1_use -gt 94 ] && status="warning" && message="disk1=$disk1_use%"
[ $DISK2 ] && [ $disk2_use -gt 94 ] && status="warning" && message="disk1=$disk1_use% disk2=$disk2_use%"

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
      "status":"$status",
      "disk1":"$disk1_use",
      "disk2":"$disk2_use",
      "disk3":"$disk3_use",
      "memory":"$mem_use",
      "swap":"$swap_use",
      "cpu":"$cpu_use",
      "internal_ip":"$int_ip",
      "external_ip":"$ext_ip",
      "message":"$message",
      "info":"$info"
  }
}
EOF

cat $json | jq
