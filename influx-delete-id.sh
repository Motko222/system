#!/bin/bash

[ -z %1 ] && read -p "id? " id || id=$1
source ~/.bash_profile

curl --request POST "$INFLUX_HOST/api/v2/delete?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "start": "2020-03-01T00:00:00Z",
    "stop": "2029-11-14T00:00:00Z",
    "predicate": "_measurement=\"report\" AND id=\"'$id'\" AND owner=\"'$OWNER'\""
  }'
