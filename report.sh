#!/bin/bash

source ~/.bash_profile

version=$(cat ~/aethir/log/server.log | grep "Initialize Service Version: " | head -1 | awk -F "Initialize Service Version: " '{print $NF}' | awk '{print $1}')
service=$(sudo systemctl status aethir-checker --no-pager | grep "active (running)" | wc -l)
pid=$(pidof AethirCheckerService)
chain=$AETHIR_CHAIN
network=$AETHIR_NETWORK
type=$AETHIR_TYPE
owner=$AETHIR_OWNER
id=$AETHIR_ID
chain=$AETHIR_CHAIN
group=$AETHIR_GROUP
json=$(cat ~/aethir/log/server.log | grep "capacityLimit" | tail -1 | awk -F "Success to send: " '{print $NF}')
delegated=$(echo $json | jq -r .data.delegatedLicense)
pending=$(echo $json | jq -r . .data.pendingLicenses)
checking=$(echo $json | jq -r .data.checking)
banned=$(echo $json | jq -r .data.banned)
ready=$(echo $json | jq -r .data.ready)


if [ $service -ne 1 ]
then
  status="error";
  message="service not running"
else
  status="ok";
  message="checking $checking pending $pending";
fi

#if [ -z $pid ]
#then
#  status="error";
#  message="process not running"
#else
#  status="ok";
#fi

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "chain":"$chain",
  "network":"$network",
  "owner":"$owner",
  "type":"$type",
  "version":"$version",
  "status":"$status",
  "message":"$message",
  "service":$service,
  "pid":$pid,
  "delegated":"$delegated",
  "pending":"$pending",
  "checking":"$checking",
  "banned":"$banned",
  "ready":"$ready",
  "updated":"$(date --utc +%FT%TZ)"
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
    report,id=$id,machine=$MACHINE,owner=$owner,grp=$group status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\",type=\"$type\" $(date +%s%N)
    "
fi
