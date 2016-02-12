#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

package require Expect

#   set sshcmd [concat "ssh " [join $sshargs " "] -l $user $host]
#   set pid [spawn {*}$sshcmd]
# 
#   set logged_in 0
#   expect "$user@$host's password:" {
#     send "$password(old)\r"
#     expect -re "$prompt" {
#       set logged_in 1
#     } -re {Permission denied([^\r\n])*} {
#       set badhosts($host) $expect_out(0,string)
#       exec kill $pid
#       expect eof
#     }
#   } timeout {

set prompt              ".*(%|\\\$|#) "

set pid [spawn $env(SHELL)]
expect -re $prompt
send "getent passwd | awk -F: '\{print \$1\}'\r"
set accum {}
expect {
  -regexp $prompt {
    send "exit\r"
  }
  -regexp {..*} {
    set accum "${accum}$expect_out(0,string)"
    exp_continue
  }
}
# expect -re $prompt
# send "exit\r"
expect eof
puts $accum
exit

set users [exec getent passwd | awk -F: {{print $1}}]
foreach user $users {
  set chage [split [exec sudo chage -l $user] "\n"]
  foreach line $chage {
    if {[string match {Account expires*} $line] == 1} {
      set expiration $line
      break
    }
  }
  set expiration [string trim [regsub {Account expires} $expiration ""] ":\t "]
  if ![string equal $expiration "never"] {
    set daysSince1970 [expr [exec date -d $expiration +%s]/(60*60*24)]
    if ![string equal $daysSince1970 0] {
      set accountActive($user) 1
    } else {
      set accountActive($user) 0
    }  
  } else {
    set accountActive($user) 1
  }
}

foreach {user isActive} [array get accountActive] {
  if [string equal $isActive 1] {
    puts [format "Account active: %-13s" $user]
  }
}

foreach {user isActive} [array get accountActive] {
  if [string equal $isActive 0] {
    puts [format "Account disabled: %-13s" $user]
  }
}


















