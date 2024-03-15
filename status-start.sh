#!/bin/bash

pkill -f "status-daemon"
sleep 5s
bash ~/scripts/system/status-daemon.sh > /dev/null &
