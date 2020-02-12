#!/usr/local/bin/bash

_output=$(syspatch -c)

if test -n "$_output"; then
  echo "$_output" | mail -s "Syspatch check" bryan@sally.org.il
fi
