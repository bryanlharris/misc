#!/bin/bash

# Usage
[[ -z "$1" ]] && echo "`basename $0` [options] str1 str2 etc. [(d)ebug,(a)ddresses,(i)gnore case]" >&2 && exit 2
trap "rm -f $_select $_awkcmd" SIGINT SIGTERM

# Grab some things from a config file
_user=`grep -A5 pmp ~/.neoconfig | awk -F'[ \t]+=[ \t]+' '$1 ~ /user/ {print $NF}'`
_pass=`grep -A5 pmp ~/.neoconfig | awk -F'[ \t]+=[ \t]+' '$1 ~ /pass/ {print $NF}'`
_host=`grep -A5 pmp ~/.neoconfig | awk -F'[ \t]+=[ \t]+' '$1 ~ /host/ {print $NF}'`
_port=`grep -A5 pmp ~/.neoconfig | awk -F'[ \t]+=[ \t]+' '$1 ~ /port/ {print $NF}'`
_data=`grep -A5 pmp ~/.neoconfig | awk -F'[ \t]+=[ \t]+' '$1 ~ /data/ {print $NF}'`
_opts= && _opts="-N -u$_user -p$_pass -h$_host -P$_port $_data"

# Script, then config file, then cli
DEBUG=0 && ADDRESS=0 && IGNORECASE=0 && \
  eval $(grep DEBUG ~/.neoconfig) && \
  eval $(grep ADDRESS ~/.neoconfig) && \
  eval $(grep IGNORECASE ~/.neoconfig)
while getopts "dai" options; do
	case $options in
		d ) DEBUG=1 ;;
		a ) ADDRESS=1 ;;
        i ) IGNORECASE=0 ;;
	esac && shift
done

# Build a simple regex search
for arg in "$@"; do search="$search.*$arg"; done; search="$search.*"
[[ $DEBUG -eq 1 ]] && echo $search

# An awk command to format the output
_awkcmd= && _awkcmd=`mktemp` && [ -f "$_awkcmd" ] || error $? "mktemp failed"
chmod 755 $_awkcmd
cat >$_awkcmd <<_EOF_
#!/usr/bin/awk -f
{
    ADDRESS=$ADDRESS
    IGNORECASE=$IGNORECASE
    if (\$0 ~ /$search/)
    {
        if (ADDRESS==0)
        {
            printf "%-7s ", \$1
            printf "%-10s ", \$2
            printf "%-30s ", \$3
            printf "%-16s ", \$4
            printf "%s %s %s\n", \$5, \$6, \$7
        } else {
            print \$4
        }
    }
}
_EOF_

# A slightly modified select statement
_select= && _select=`mktemp` && [ -f "$_select" ] || error $? "mktemp failed"
cat >$_select <<_EOF_
select rs.operatingsystem, r.column_char2, r.column_char4, r.ipaddress, r.column_char3
from ptrx_resource r left join ptrx_resourcesystemmembers rsm on r.resourceid = rsm.resourceid
left join ptrx_resourcesystem rs on rsm.osid = rs.osid where
concat_ws(' ', rs.operatingsystem, r.column_char2, r.column_char4, r.ipaddress, r.column_char3) regexp '$search'
_EOF_

# Print output and clean up
$_awkcmd <(mysql $_opts <$_select)
rm -f $_select $_awkcmd
