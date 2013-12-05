#!/bin/bash

query()
{
   nslookup ${domain} | sed -n '/^[^A-Z]/p' | tail -n 1 | awk '{print $NF}' 2> /dev/null 
}

while read line; do
      ary=(${line//./ })
      if [[ "${line}" =~ ^\. ]]; then
            domain="www${line}"
      elif (( ${#ary[@]} == 2 )); then
            domain="www.${line}"
      else
             domain="${line}"
      fi
             #echo "${line} ${domain}"
            if nslookup ${domain} &> /dev/null; then
               echo "${line}      CNAME	   600        $(query)" >> success_list
            else
               echo "${line}" >> failed_list
            fi

done < ${1}
