#/bin/bash

while IFS=: read name passwd uid gid fullname ignore
do
  echo "$name($fullname)"
done</etc/passwd

echo
echo "$IFS still $IFS"

exit 0
