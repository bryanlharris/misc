#! /usr/bin/gawk --exec

# ~/.neoconfig
# 
# |<--beginning of the line is here, i.e. does not start w/space
#
# [pmp]
#     user = pmpnerd
#     pass = ommitted
#     host = passman
#     port = 2345
#     data = passtrix


BEGIN \
{
    if(ARGV[1] == "") {
        printf "usage: ./search string1 string2 string3\n\n"
        printf "note: needs a file .neoconfig, see comments\n"
        printf "note: edit line 26 to set the neoconfig location\n"
        printf "note: edit line 46 to allow more than three search strings\n"
        exit
    }

    RS = "\n\\["; FS = " "
    while((getline < "/home/bharris/.neoconfig") >0)
    {
        if(tolower($0) ~ /pmp/)
        {
            stanza = $0
            sub(/pmp]\n/, "", stanza)
            RS = "\n"; FS = " = "
            user = $0; sub(/.*user = /, "", user); sub(/\n.*/, "", user)
            pass = $0; sub(/.*pass = /, "", pass); sub(/\n.*/, "", pass)
            host = $0; sub(/.*host = /, "", host); sub(/\n.*/, "", host)
            port = $0; sub(/.*port = /, "", port); sub(/\n.*/, "", port)
            data = $0; sub(/.*data = /, "", data); sub(/\n.*/, "", data)
            RS = "\n"; FS = " "
            break
        }
    }

    cmd="mysql -N -u" user " -p"pass" -h"host" -P"port " " data
    print "select rs.operatingsystem, r.column_char2, r.column_char4, r.ipaddress, r.column_char3 from ptrx_resource r left join ptrx_resourcesystemmembers rsm on r.resourceid = rsm.resourceid left join ptrx_resourcesystem rs on rsm.osid = rs.osid where concat_ws(' ', rs.operatingsystem, r.column_char2, r.column_char4, r.ipaddress, r.column_char3) regexp '.'"|&cmd
    close(cmd,"to")
    while((cmd|&getline)>0)
    {
        r["id"]=count++
        r["os"]=$1
        r["ticker"]=$2
        r["name"]=$3
        r["addr"]=$4
        r["customer"]=$5 " " $6 " " $7

        if((tolower($0) ~ ARGV[1]) && (tolower($0) ~ ARGV[2]) && (tolower($0) ~ ARGV[3]))
        {
#             printf "%d: ",  r["id"]
            printf "%-08s", r["os"]
            printf "%-11s", r["ticker"]
            printf "%-31s", r["name"]
            printf "%-17s", r["addr"]
            printf "%s\n",  r["customer"]
        }
    }
    close(cmd)
}
