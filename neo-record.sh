#!/bin/bash

echo $1 | grep -q '^[[:digit:]]\{6\}$'
if [ $? -eq 0 ]; then
    TICKET=$1
    if [ ! -d $HOME/tickets/$TICKET ]; then
        mkdir $HOME/tickets/$TICKET
    fi
    cd $HOME/tickets/$TICKET || exit 1
    script -f -t `date +%s` 2>`date +%s`-
    cd $HOME/tickets
    git status
else
    cd $HOME/alerts
    script -f -t `date +%s` 2>`date +%s`-
    cd $HOME/alerts
    git status
fi
