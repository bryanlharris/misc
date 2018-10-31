#!/bin/bash

trap "exit" SIGINT SIGTERM

shutdown() {
  kill `cat /path/to/tomcat/catalina.pid`

  while ps -p `cat /path/to/tomcat/catalina.pid` > /dev/null; do
    for i in `seq 1 5`; do
      sleep 1
      if ps -p `cat /path/to/tomcat/catalina.pid` > /dev/null; then
        kill `cat /path/to/tomcat/catalina.pid`
      fi
    done
    if ps -p `cat /path/to/tomcat/catalina.pid` > /dev/null; then
      kill -9 `cat /path/to/tomcat/catalina.pid`
    fi
    sleep 1
  done
}

cleanup() {
  if ! ps -p `cat /path/to/tomcat/catalina.pid` > /dev/null; then
    cd /path/to/tomcat/work
    rm -rf Catalina
  fi
}

startup() {
  /etc/init.d/tomcat start
}

if [ "X`id -un`" != Xtomcat ]; then
  echo "Not tomcat user, exiting."
  exit 1
fi

shutdown
cleanup
startup

exit 0

