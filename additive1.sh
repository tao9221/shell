#/bin/bash

n=$1
nu=0
while [[ $n -gt 0 ]];do
   ((nu=nu+n))
   ((n=n-1))
done
echo "$nu"
