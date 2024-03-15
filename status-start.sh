#!/bin/bash

pkill -f "status-daemon"
sleep 2s
bash ~/scripts/system/status-daemon.sh 1>/dev/null 2>/dev/null &
