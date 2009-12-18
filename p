#!/bin/bash

pattern=$@
_opts="-N -upmpnerd -pRkeVfNbjv8kE9MtkBfG93t5K -h passman -P 2345 passtrix -e"
_cmd=`\
cat << _EOF_
select r.column_char2, r.column_char4, r.ipaddress, r.column_char3
from ptrx_resource r left join ptrx_resourcesystemmembers rsm on r.resourceid = rsm.resourceid
left join ptrx_resourcesystem rs on rsm.osid = rs.osid where
concat_ws(' ', r.column_char2, r.column_char3, r.column_char4, r.ipaddress) regexp '$pattern'
_EOF_
`

awk\
  '{\
    printf "%-10s ", $1;\
    printf "%-30s ", $2;\
    printf "%-16s ", $3;\
    printf "%s %s %s", $4, $5, $6;\
    printf "\n"\
  }'\
  <(mysql $_opts "$_cmd")
