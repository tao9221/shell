#!/bin/bash
PassWord="passwd"
HostName=`hostname`
for ip in `cat ip`
do
expect << EXP
spawn scp /usr/local/haproxy/etc/haproxy.cfg root@$ip:/usr/local/haproxy/etc/haproxy.cfg
  set timeout 3600
  expect {
          "yes/no" { send "yes\r" }
          "password:" { send "$PassWord\r" }
  }
  expect {
          "Permission denied" { send_user "\nPassword wrong for host $HostName\n" }
          timeout {
                   send_user "\nPassword wrong for host $HostName\n"
                   exit 1
          }
          eof
  }
EXP
done