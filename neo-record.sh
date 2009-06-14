#!/bin/bash

echo $1 | grep -q '^[[:digit:]]\{6\}$'
if [ $? -eq 0 ]; then
    TICKET=$1
    if [ ! -d /home/bharris/tickets/$TICKET ]; then
        mkdir /home/bharris/tickets/$TICKET
    fi
    cd /home/bharris/tickets/$TICKET || exit 1
    script -f -t `date +%s` 2>`date +%s`-
    cd /home/bharris/tickets
    git status
else
    cd /home/bharris/alerts
    script -f -t `date +%s` 2>`date +%s`-
    cd /home/bharris/alerts
    git status
fi
