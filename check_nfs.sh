#!/bin/bash

HOSTNAME=$(hostname)
IPADDR=$(/sbin/ip a |awk -F"[ /]" '/inet.*global/{print $6}'|tail -n1)
REFILE=$(pwd)/remotefile.txt
LOGDIR=$(pwd)/logCheck.log
PRO_PWD='xxxxx'

wlog(){
    echo -e "$(date +%F_%T) -  $1" >>$LOGDIR
}

get_info(){
    cpu_info=$(uptime)
    cpu_number=$(grep "cpu cores" /proc/cpuinfo | uniq | awk -F":" '{print $NF}')
    uptimes=$(echo ${cpu_info} | awk '{print $3,$4}'|sed 's#,##g')
    cpu_use=$(echo ${cpu_info} | awk '{print $(NF-2),$(NF-1)}'| sed 's#,$##g')

    mem_info=$(/usr/bin/top -b -n 1 | egrep 'KiB Mem|^Mem')
    mem_total=$(echo ${mem_info} | awk '{print $4}' | sed 's#k##g')
    mem_use=$(echo ${mem_info} | awk '{print $8}' | sed 's#k##g')
    mem_per=$(awk -v mem_use=$mem_use -v mem_total=$mem_total 'BEGIN{printf "%.2f\n",(mem_use/mem_total)}')

    disk_info=$(/bin/df -h)
    disk_warn=$(/bin/df -h | while read line;do echo $line|awk -F"[ %]" '$(NF-2)>70{print}';done)
    app_test_write=$(echo $(date +%F_%T)>>/app/txt && echo $?)
    root_test_write=$(echo $(date +%F_%T)>>/tmp/txt && echo $?)
}

nfs_info(){
    message=""
    now_nfs_mount_ip=$(for n in $(seq 2);do netstat -nat|egrep "${IPADDR}:2049";sleep 4;done |awk  '{sub(/:[0-9]+/,"",$(NF-1));num[$(NF-1)]+=1}END{for(i in num)print i}') 
    old_nfs_mount_ip=$(awk -F"|" '{num[$1]++}END{for(n in num){print n}}' ${REFILE})
    nfs_status=$(for i in ${old_nfs_mount_ip};do echo -n "$i|";echo $now_nfs_mount_ip | grep -sw "$i" 2>&1 >>/dev/null;echo $?;done)
    for j in ${nfs_status};do
        [[ -n $j ]] && status=$(echo $j|awk -F"|" '$NF==1{print $2}') && ip_err=$(echo $j|awk -F"|" '$NF==1{print $1}')
        [[ ${status} == 1 ]] && message="${message}\n${ip_err}"
    done
    if [[ ${#message} > 10 ]] || [[ ${app_test_write} != 0 ]] || [[ ${root_test_write} != 0 ]];then
        error_message=$(echo -e "${message}"|while read m;do sed -n '/'$m'/p' ${REFILE} 2>/dev/null;done)
        wlog "$error_message"
        while read line;do
           number=$(echo $line|awk '{split($0,data,"|");print length(data)}')
           if [[ $number -eq 3 ]];then
               okmessage=""
               remote_ip=$(echo $line|awk -F"[|:]" '{print $1}')
               nfs_server=$(echo $line|awk -F"[|:]" '{print $2}')
               nfs_server_mount=$(echo $line|awk -F"[|:]" '{print $3}')
               remote_mount=$(echo $line|awk -F"[|:]" '{print $4}')
               stat=$(nc -v -w 3 $remote_ip -z 22 2>/dev/null | awk -F"[!| ]" '{print $(NF-1)}')
               if [[ $stat == 'succeeded' ]];then
                   /usr/bin/sshpass -p "${PRO_PWD}" /usr/bin/ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 user@$remote_ip "sudo mount -t nfs ${nfs_server}:${nfs_server_mount} ${remote_mount}" 
                   #echo "mount -t nfs ${nfs_server}:${nfs_server_mount} ${remote_mount}"
                   [[ $? == 0 ]] && okmessage="$okmessage\n$line 自动挂载成功."
               fi
           else
               continue
           fi
        done <<<"$(echo -e "$error_message")"
        wlog "$okmessage" 
        cat >$(pwd)/message<<EOF
<html>
<header>NFS报警来自地址${IPADDR}</header>
<meta charset="utf-8">
<body>
<p style="background-color:red"><big>$(date +%F_%T) 下列挂载失败</big>:</p>
$(while read line;do echo "<p>$line</p>";done <<<"$(echo -e "${error_message}")")
<p style="background-color:green"><big>$(date +%F_%T) 自动挂载成功:</big></p>
$(while read line;do echo "<p>$line</p>";done <<<"$(echo -e "${okmessage}")")

<p style="background-color:blue"><big>机器资源信息:</big></p>
<p>启动时间:${uptimes}</p>
<p>CPU核数:${cpu_number}</p>
<p>1分钟,5五分钟负载值: ${cpu_use}</p>
<p>总内存: $((mem_total/1024))MB</p>
<p>使用内存: $((mem_use/1024))MB</p>
<p>内存使用率: ${mem_per}%</p>

<p style="background-color:blue"><big>磁盘使用情况:</big></p>
$(while read line;do echo "<p>$line</p>";done <<<"$(echo -e "${disk_info}")")

<p style="background-color:red"><big>下列磁盘使用率过高:</big></p>
$(while read line;do echo "<p>$line</p>";done <<<"$(echo -e "${disk_warn}")")

<p style="background-color:blue"><big>注意:状态非 0 为不可写状态,需要登录服务器查看</big></p>
<p>/app  可写状态:${app_test_write}</p>
<p>/     可写状态:${root_test_write}</p>
</body>
</html>
EOF
    python mail.py 'NFS挂在检测报警' alter@mail.cn "$(cat $(pwd)/message)"
    fi
}
get_info
nfs_info
