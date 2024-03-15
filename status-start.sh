#!/bin/bash

pkill -f "status-daemon"
sleep 2s
bash ~/scripts/system/status-daemon.sh > /dev/null &
