#!/bin/bash

read -p "host? " host

curl -X POST $host -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
