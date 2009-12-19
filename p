#!/bin/bash

[[ -z "$1" ]] && echo "Usage: `basename $0` [-d] string1 string2 etc. (-d for debugging)" >&2 && exit 2
[[ "$1" == "-d" ]] && debug="1" && shift

for arg in "$@"; do search="$search.*/$arg"; done; search="${search#*/}"; search=${search//.*\//.*}
[[ ! -z "$debug" ]] && echo $search

_opts="-N -upmpnerd -pRkeVfNbjv8kE9MtkBfG93t5K -h passman -P 2345 passtrix -e"
_cmd=`\
cat << _EOF_
select rs.operatingsystem, r.column_char2, r.column_char4, r.ipaddress, r.column_char3
from ptrx_resource r left join ptrx_resourcesystemmembers rsm on r.resourceid = rsm.resourceid
left join ptrx_resourcesystem rs on rsm.osid = rs.osid where
concat_ws(' ', rs.operatingsystem, r.column_char2, r.column_char3, r.column_char4, r.ipaddress) regexp '$search'
_EOF_
`

awk\
  '{\
    printf "%-7s ", $1;\
    printf "%-10s ", $2;\
    printf "%-30s ", $3;\
    printf "%-16s ", $4;\
    printf "%s %s %s", $5, $6, $7;\
    printf "\n"\
  }'\
  <(mysql $_opts "$_cmd")
