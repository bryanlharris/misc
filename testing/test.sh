#!/bin/bash

for user in $(getent passwd | awk -F: '{print $1}'); do
  _date=$(sudo chage -l $user | awk -F': ' '/Account expires/ {print $NF}')
  if [ "$_date" != "never" ]; then
    _days=$(($(date -d "$_date" +%s)/$((60*60*24))))
    if [ "$_days" != "0" ]; then
      printf "Account active: %-13s\n" $user
    elif [ "$_days" = "0" ]; then
      printf "Account disabled: %-13s\n" $user
    fi
  else
    printf "Account active: %-13s\n" $user
  fi
done
