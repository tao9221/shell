#!/bin/bash

clear
echo -e "$(uname -nro) $(cat /etc/redhat-release)\n"
modname="$(grep "model name" /proc/cpuinfo | awk -F: '{print $2}' | uniq)"
procnum="$(grep processor /proc/cpuinfo | wc -l)"
echo -e "CPU  ${modname} ${procnum}\n"
grep MemTotal /proc/meminfo
grep SwapTotal /proc/meminfo
echo -e "\nDisk Size"
fdisk -l | grep "^Disk /dev" | awk -F'[:, ]+' '{print $2,$3,$4}'
echo -e "\nFilesystem    Type    Size  Used Avail Use% Mounted on"
df -Th | awk '/^\/dev/'
echo -e "\nEthernet"
lspci | grep Ethernet | awk -F: '{print $NF}' | sort -n | uniq
echo -e "\nipaddr"
ip a | awk '/mtu/||/inet /{print $2}' | sed 'N;s/:\n/ /' | column -t
if [[ -s /etc/init.d/ipmi ]]; then
   /etc/init.d/ipmi status | grep not &> /dev/null
   (( $? == 0 )) && /etc/init.d/ipmi start  &> /dev/null
   ipmitool lan print | awk 'NR>7 && NR <15'
fi
sepgg="##################"
echo -e "\n${sepgg}${sepgg}${sepgg}\n"
