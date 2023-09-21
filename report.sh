#!/bin/bash

source ~/scripts/system/config/env

d1=$(df | grep -E $disk1 | awk '{print $5}' | sed 's/%//')
d2=$(df | grep -E $disk2 | awk '{print $5}' | sed 's/%//')
memUsed=$(free | grep Mem | awk '{print $3 / $2 * 100}' | cut -d , -f 1 | awk '{printf "%.0f\n",$1}')
swapUsed=$(free | grep Swap | awk '{print $3 / $2 * 100}'| cut -d , -f 1 | awk '{printf "%.0f\n",$1}')
cpuUsed=$(top -bn2 | grep '%Cpu' | tail -1 | grep -P '(....|...) id,'|awk '{print 100-$8}')
ip=$(hostname -I | cut -d' ' -f1)

cpuType=$(lscpu | grep "Model name" | awk -F "Intel\(R\) Core\(TM\) |AMD " '{print $2}')
memSize=$(free -h | grep Mem | awk '{print $2}')
swapSize=$(free -h | grep Swap | awk '{print $2}')
cores=$(lscpu | grep "CPU(s):" | head -1 | awk '{print $2}')

echo "updated='$(date +'%y-%m-%d %H:%M')'"
echo "disk1="$d1
echo "disk2="$d2
echo "memory="$memUsed
echo "swap="$swapUsed | sed 's/nan//g'
echo "cpu="$cpuUsed
echo "system='$cpuType, $memSize RAM, $swapSize swap, $cores cores'"
echo "ip="$ip
