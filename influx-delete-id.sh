#!/bin/bash

read -p "id? " id
source ~/.bash_profile

curl --request POST "https://db.antares.zone:8086/api/v2/delete?org=prod&bucket=main" \
  --header "Authorization: Token X-K21ae_9PqI2iFuFnUUk7riDE-eNNiW9Qy4APn9y8KJ7hPIbQo6-TOqB5IO4sxZWK92xZthRBs6ozTuEjMhvg==" \
  --header "Content-Type: application/json" \
  --data '{
    "start": "2020-03-01T00:00:00Z",
    "stop": "2029-11-14T00:00:00Z",
    "predicate": "_measurement=\"report\" AND id=\"'$id'\" AND owner=\"'$OWNER'\""
  }'
