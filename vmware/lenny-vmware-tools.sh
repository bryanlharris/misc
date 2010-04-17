#!/bin/bash

aptitude -y install autoconf automake binutils cpp gcc linux-headers-$(uname -r) make psmisc gcc-4.1
ln -sf /usr/bin/gcc-4.1 /usr/bin/gcc

( cd /usr/share
  tar xzf /mnt/VMwareTools-7.8.6-185404.tar.gz
  ( cd vmware-tools-distrib
    ./vmware-install.pl default
  )
  rm -rf vmware-tools-distrib
)

aptitude purge autoconf automake binutils cpp gcc linux-headers-$(uname -r) make psmisc gcc-4.1
reboot
