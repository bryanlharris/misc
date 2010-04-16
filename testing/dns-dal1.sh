#!/bin/bash

set -e
exec 1>>/home/bharris/cron.log
exec 2>>/home/bharris/cron.log

[ `whoami` = "bharris" ]   # Make sure user is bharris
ssh -n -T sr               # Make sure sr is alive on 22
pgrep git && exit

( cd ~/src/git/dns-dal1
  git svn rebase svn+ssh://svn@sr/svn/dns-dal1
  git push shared --all
)

( cd ~/src/git/nerds
  git svn rebase svn+ssh://svn@sr/svn/nerds
  git push shared --all
)
