#!/bin/bash

set -e
exec 1>>/home/bharris/cron.log
exec 2>>/home/bharris/cron.log

export CVS_RSH="/usr/bin/ssh"
export CVSROOT="bharris@sr:/usr/home/cvs/root"

# Simple pre-run checks
[ `whoami` = "bharris" ]   # Make sure user is bharris
ssh -n -T sr.neospire.net  # Make sure sr is alive on 22
pgrep -f cvsimport && exit
pgrep git && exit

# Pull recent changes then push to shared repository
( cd ~/src/git/nagios-cfg
  git cvsimport -v -a -d :ext:bharris@sr.neospire.net:/usr/home/cvs/root/ nagios-cfg
  git push shared --all
)
