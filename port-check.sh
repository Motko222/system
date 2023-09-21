#!/bin/bash

read -p "Port? " port
echo "------------------------"
lsof -i :$port
