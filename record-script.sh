#!/bin/bash

TICKET=$1

echo $TICKET | grep -q '^[[:digit:]]\{6\}$'
if [ $? -ne 0 ]; then
    printf "Error aborting"
    exit 1
fi

if [ ! -d /home/bharris/tickets/$TICKET ]; then
    mkdir /home/bharris/tickets/$TICKET
fi

cd /home/bharris/tickets/$TICKET
exec script -f -t `date +%s` 2>`date +%s`-
