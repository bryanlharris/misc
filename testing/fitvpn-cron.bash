#!/bin/bash

ssh 10.2.199.21 ping -c1 172.16.22.129 >/dev/null <&1 2>&1
if [ $? -eq "0" ]; then
    echo success >> ~/log/fitvpn.log
    exit
fi

echo failure >> ~/log/fitvpn.log
/home/bharris/src/git/misc/new/fitvpn.exp >/dev/null 2>&1
echo successful reconnection >> ~/log/fitvpn.log
