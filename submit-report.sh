#/bin/bash

json=$1

[ -z $INFLUX_HOST ] && exit

# send data to influxdb
tag_count=$(cat $json | jq '.tags | length')
field_count=$(cat $json | jq '.fields | length')

data=$(cat $json | jq -r '.measurement')","

for (( i=0; i<$tag_count; i++ ))
do
 key=$(cat $json | jq .tags | jq -r keys[$i])
 value=$(cat $json | jq .tags | jq -r --arg a $key '.[$a]')
 data=$data$key"="$value
 [ $i -lt $(( tag_count - 1 )) ] && data=$data"," || data=$data" "
done

for (( i=0; i<$field_count; i++ ))
do
 key=$(cat $json | jq .fields | jq -r keys[$i])
 value=$(cat $json | jq .fields | jq -r --arg a $key '.[$a]')
 data=$data$key"=\""$value"\""
 [ $i -lt $(( field_count - 1 )) ] && data=$data"," || data=$data" "$(date +%s%N)
done

if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "$data"
fi
