#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
source /root/.bash_profile
source $path/config

printf "%s started \n" $(date --utc +%FT%TZ)

rm /root/logs/report-*

for i in $(find -L $REPO_PATH -name "report.sh")
do
 printf "%s running %s \n" $(date --utc +%FT%TZ) $i
 bash $i
done

[ -z $INFLUX_HOST ] && exit

printf "%s submitting to influxdb\n" $(date --utc +%FT%TZ)
for i in ~/logs/report-*
do
   echo $i
   tag_count=$(cat $i | jq '.tags | length')
   field_count=$(cat $i | jq '.fields | length')
   
   data=$(cat $i | jq -r '.measurement')","
   
   for (( j=0; j<$tag_count; j++ ))
   do
    key=$(cat $i | jq .tags | jq -r keys[$j])
    value=$(cat $i | jq .tags | jq -r --arg a $key '.[$a]')
    data=$data$key"="$value
    [ $j -lt $(( tag_count - 1 )) ] && data=$data"," || data=$data" "
   done
   
   for (( j=0; j<$field_count; j++ ))
   do
    key=$(cat $i | jq .fields | jq -r keys[$j])
    value=$(cat $i | jq .fields | jq -r --arg a $key '.[$a]')
    data=$data$key"=\""$value"\""
    [ $j -lt $(( field_count - 1 )) ] && data=$data"," || data=$data" "$(date +%s%N)
   done
   
   if [ ! -z $INFLUX_HOST ]
   then
    curl --request POST \
    "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
     --header "Authorization: Token $INFLUX_TOKEN" \
     --header "Content-Type: text/plain; charset=utf-8" \
     --header "Accept: application/i" \
     --data-binary "$data"
   fi

done

printf "%s ended \n" $(date --utc +%FT%TZ)
