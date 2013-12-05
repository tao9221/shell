#!/bin/bash

awk -F'[: ]+' '/2012-02-01/{
       if($2 > 11 && $2 <= 23)print $0}' $1 | \
awk -F: '{if(($2%2) != 0)
              $2-=1
          OFS=":"
          print $0
         }' 

: << EOF
awk -F'[: ]+' '{++a[$1" "$2":"$3]; b[$1" "$2":"$3]=b[$1" "$2":"$3]"\n"$5":"$6":"$7" "$8" "$9} END{for(i in a){print i,a[i],b[i]}}' log_purge.file > log_sum
EOF
