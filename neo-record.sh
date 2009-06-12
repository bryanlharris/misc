#!/bin/bash

COMMAND=$1
TICKET=$2
CWD=`pwd`

echo $COMMAND | grep -q '^ticket\|alert$'
if [ $? -ne 0 ]; then
    printf "Error aborting"
    exit 1
fi

if [ $COMMAND == "ticket" ]; then
    echo $TICKET | grep -q '^[[:digit:]]\{6\}$'
    if [ $? -ne 0 ]; then
        printf "Error aborting"
        exit 1
    fi
    if [ ! -d /home/bharris/tickets/$TICKET ]; then
        mkdir /home/bharris/tickets/$TICKET
    fi
    cd /home/bharris/tickets/$TICKET
    script -f -t `date +%s` 2>`date +%s`-
    cd $CWD/tickets
    git status
elif [ $COMMAND == "alert" ]; then
    if [ ! -d /home/bharris/alerts ]; then
        mkdir /home/bharris/alerts
    fi
    cd /home/bharris/alerts
    script -f -t `date +%s` 2>`date +%s`-
    cd $CWD
fi

