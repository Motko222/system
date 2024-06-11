!/bin/bash

source ~/.bash_profile

disk1_use=$(df | grep -E $DISK1 | awk '{print $5}' | sed 's/%//')
disk2_use=$(df | grep -E $DISK2 | awk '{print $5}' | sed 's/%//')
mem_use=$(free | grep Mem | awk '{print $3 / $2 * 100}' | cut -d , -f 1 | awk '{printf "%.0f\n",$1}')
swap_use=$(free | grep Swap | awk '{print $3 / $2 * 100}'| cut -d , -f 1 | awk '{printf "%.0f\n",$1}')
cpu_use=$(top -bn2 | grep '%Cpu' | tail -1 | grep -P '(....|...) id,'| awk '{print 100-$8}' | sed 's/,/./g')
ip=$(hostname -I | cut -d' ' -f1)

cpu_type=$(lscpu | grep "Model name" | awk -F "Intel\(R\) Core\(TM\) |AMD " '{print $2}')
mem_size=$(free -h | grep Mem | awk '{print $2}')
swap_size=$(free -h | grep Swap | awk '{print $2}')
cores=$(lscpu | grep "CPU(s):" | head -1 | awk '{print $2}')
info="$cpu_type, $mem_size RAM, $swap_size swap, $cores cores"
group=machine

# show json output 
cat << EOF
{
  "machine":"$MACHINE",
  "disk1":"$disk1_use",
  "disk2":"$disk2_use",
  "memory":"$mem_use",
  "swap":"$swap_use",
  "cpu":"$cpu_use",
  "ip":"$ip",
  "message":"$message",
  "info":"$info",
  "updated":"$(date --utc +%FT%TZ)",
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$MACHINE,grp=$group disk1=\"$disk1_use\",disk2=\"$disk2_use\",memory=\"$mem_use\",swap=\"$swap_use\",cpu=\"$cpu_use\",ip=\"$ip\",message=\"$message\",info=\"$inf>
    "
fi
