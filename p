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
DEBUG=0 && \
ADDRESS=0 && \
IGNORECASE=0 && \
FULLNAME=0 && \
SINGLE=0 && \
  eval $(grep DEBUG ~/.neoconfig) && \
  eval $(grep ADDRESS ~/.neoconfig) && \
  eval $(grep IGNORECASE ~/.neoconfig) && \
  eval $(grep FULLNAME ~/.neoconfig) && \
while getopts "daifs" options; do
	case $options in
		d ) DEBUG=1 ;;
		a ) ADDRESS=1 ;;
        i ) IGNORECASE=0 ;;
        f ) FULLNAME=1 ;;
        s ) ADDRESS=1 ; SINGLE=1 ;;
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
    FULLNAME=$FULLNAME
    ADDRESS=$ADDRESS
    IGNORECASE=$IGNORECASE
    if ((\$0 ~ /$search/) && (\$0 !~ /aoeuatl/))
    {
        if (ADDRESS==0)
        {
            printf "%-7s ", \$1
            printf "%-10s ", \$2
            printf "%-30s ", \$3
            printf "%-16s ", \$4
            if (FULLNAME==1) {
                printf "%s %s %s", \$5, \$6, \$7
            }
            printf "\n"
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

# For now this is a way to get the last IP on the line into my buffer
_xselfile= && _xselfile=`mktemp` && [ -f "$_xselfile" ] || error $? "mktemp failed"

# Print output and clean up
[ "$SINGLE" -eq "0" ] && $_awkcmd <(mysql $_opts <$_select) | tee $_xselfile
[ "$SINGLE" -eq "1" ] && $_awkcmd <(mysql $_opts <$_select) | tee $_xselfile | tr '\n' ' '
[ "$SINGLE" -eq "0" ] && cat $_xselfile | tail -1 | awk '{print $4}' | tr -d '\n' | xsel -b -i
rm -f $_select $_awkcmd $_xselfile
