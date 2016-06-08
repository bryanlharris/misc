#!/bin/bash

_pidstatCmd ()
{
  eval `perl -ne 'if (/BEGIN PIDSTAT COMMAND/../END PIDSTAT COMMAND/) {print unless /===/}' $0`
}

_iopingCmd ()
{
  eval `perl -ne 'if (/BEGIN IOPING COMMAND/../END IOPING COMMAND/) {print unless /===/}' $0`
}

set -e

_pidstatLogFile=/var/log/pidstat-current
_iopingLogFile=/var/log/ioping-current

>$_pidstatLogFile
>$_iopingLogFile

( for i in `seq 1 24`; do
    _pidstatCmd
    for j in `seq 1 119`; do
      sleep `expr 30 - \`date +%s\` % 30`
      _pidstatCmd
    done
  done
) >> $_pidstatLogFile &
_pidstatPid=$!

( for i in `seq 1 24`; do
    _iopingCmd
    for j in `seq 1 119`; do
      sleep `expr 30 - \`date +%s\` % 30`
      _iopingCmd
    done
  done
) >> $_iopingLogFile &
_iopingPid=$!

trap "{ kill $_pidstatPid; kill $_iopingPid; pkill pidstat; pkill ioping; \
        mv $_iopingLogFile ${_iopingLogFile%-current}; \
        mv $_pidstatLogFile ${_pidstatLogFile%-current}; }" SIGINT SIGTERM

sleep 86280
kill $_pidstatPid || true
pkill pidstat || true
kill $_iopingPid || true
pkill ioping || true

mv $_iopingLogFile ${_iopingLogFile%-current}
mv $_pidstatLogFile ${_pidstatLogFile%-current}

exit



# ===DO NOT REMOVE THESE LINES===



# ===BEGIN PIDSTAT COMMAND===
pidstat -duhIl 1 1 | perl -lane '$"=","; if (m/^ [0-9]+/) {chomp($F[0]=`date -d \@$F[0] +%H:%M:%S`); print join q{,}, @F[0,5,7,8,10..$#F]; };'
# ===END PIDSTAT COMMAND===

# ===BEGIN IOPING COMMAND===
{
_date=`date +%H:%M:%S`;
_latency=`ioping -q / -c 1 -p 1 | cut -d' ' -f6`;
echo "$_date,$_latency";
}
# ===END IOPING COMMAND===






