#/bin/bash

file=${1}
username="root"
echo $#
#if [[ $# == 0 ]]; then
(( $# == 0 )) &&\
    echo -e "[\e[5;32m option:file like name passwd \e[0m] USAGE:\e[1;31mPlease put your file\e[0m" || \
#else
cat $file | awk '{print $2}' | while read line
            do
              echo $line | passwd --stdin "$username"
              echo -e "\e[1;32m${username}\e[0m change password is \e[5;31m${line}\e[0m"
            done
#fi
exit 0
