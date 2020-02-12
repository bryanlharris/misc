#!/usr/local/bin/bash

# srv="P728AA11
# P728AA12
# P728AA17
# P728AA21
# P728AA22
# P728AA27
# P728DA11
# P728DA12
# P728DA21
# P728DA22"

# srv="P728WA11
# P728BA01"

# srv="P728BA01
# P728AA11
# P728AA12
# P728AA17
# P728AA21
# P728AA22
# P728AA27
# P728DA11
# P728DA12
# P728DA21
# P728DA22"

srv="T728AA11
T728AA12
T728AA07"

for s1 in $srv; do
  for s2 in $srv; do
    if [ "$s1" != "$s2" ]; then
      printf "%s,%s\n" $s1 $s2
    fi
  done
done

exit 0
