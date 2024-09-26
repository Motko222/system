#!/bin/bash

[ -z $INFLUX_HOST ] && exit

for i in ~/logs/report-*
do
   
   tag_count=$(cat $i | jq '.tags | length')
   field_count=$(cat $i | jq '.fields | length')
   
   data=$(cat $i | jq -r '.measurement')","
   
   for (( j=0; j<$tag_count; i++ ))
   do
    key=$(cat $i | jq .tags | jq -r keys[$j])
    value=$(cat $i | jq .tags | jq -r --arg a $key '.[$a]')
    data=$data$key"="$value
    [ $j -lt $(( tag_count - 1 )) ] && data=$data"," || data=$data" "
   done
   
   for (( j=0; j<$field_count; i++ ))
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
