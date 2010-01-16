#!/usr/bin/expect -f

set user        "bharris"
set prompt      "$ "
set pixcmd      "neo pix "
set fwip        "10.2.16.1"
set clearip     "206.205.156.67"
set hostname    "RCHMED-fw2"
set sshargs     "-v -k -t -2 -4 -a -q -x -p 22 -l $user"
append sshargs  " -o StrictHostKeyChecking=no"
append sshargs  " -o Compression=no"
append sshargs  " -o CheckHostIP=no"
append sshargs  " -o PasswordAuthentication=yes"
append sshargs  " -o PubkeyAuthentication=no"
append sshargs  " -o RhostsRSAAuthentication=no"
append sshargs  " -o RSAAuthentication=no"

set timeout -1
spawn $env(SHELL)
expect $prompt

send -- "$pixcmd $fwip\r"
expect -exact "
spawn ssh $sshargs $fwip\r\r\r
OpenSSH_5.1p1, OpenSSL 0.9.8g 19 Oct 2007\r\r
$user@$fwip's password: \r\r
Type help or '?' for a list of available commands.\r\r
\r$hostname> en\r\r
Password: *********\r\r
\r$hostname# "
send -- "clear isa sa $clearip\r"
expect "hostname# "
send -- "exit\r"
expect $prompt

send -- "ssh 10.2.199.21 ping -c5 172.16.22.129\r"
expect "PING 172.16.22.129 (172.16.22.129) 56(84) bytes of data.\r"

set x 0
while {$x==0} {
    expect {
        -re {64 bytes from 172\.16\.22\.129: icmp_seq=[0-9]+ ttl=128 time=[0-9]+\.[0-9]+ ms} { }
        -exact "--- 172.16.22.129 ping statistics ---\r" { set x 1 }
    }
}
expect -re {5 packets transmitted, 5 received, [0-9]+% packet loss, time [0-9]+ms}
expect -re {rtt min/avg/max/mdev = [0-9]+\.[0-9]+/[0-9]+\.[0-9]+/[0-9]+\.[0-9]+/[0-9]+\.[0-9]+ ms}

expect $prompt
send -- "exit\r"
expect eof