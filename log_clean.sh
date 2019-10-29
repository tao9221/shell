#!/bin/bash

BASE_DIR='/app/web'
NOW_TIME_T1=$(date +%Y%m%d)
NOW_TIME_T2=$(date +%Y-%m-%d)
RETAIN_DAYS=${1:-30}

warning(){
    disk_number=$(df -h|awk '/\/app$/{print $(NF-1)}'|sed 's#%##g')
    [[ $disk_number < 75 ]] && echo "disk is ok" && exit
}

wlog(){
    echo "$(date +%F_%T) - ${1}" >>${BASE_DIR}/cleanlogs.log
}

recursion(){
    for c in $(find ${1} -maxdepth 1 -print|egrep -v "${1}$");do
        if [[ -d ${c} ]];then
            recursion ${c}
        else
            filter=$(for i in $(find $c -maxdepth 1 -type f -mtime -1|egrep -v 'gz|tar|zip'|sed -e 's#|$##g');do echo -n "$(echo $i|awk -F'/' '{print $NF}')|";done|sed 's#|$##g')
            [[ -z ${filter} ]] && hulv="${NOW_TIME_T1}|${NOW_TIME_T2}" || hulv="${NOW_TIME_T1}|${NOW_TIME_T2}|${filter}"
            for r in $(find $c -type f -mtime +${RETAIN_DAYS} | egrep -v "${hulv}" |egrep "log$|tar.gz$|gz$|zip$");do
                wlog "rm -f ${r}"
                #rm -f ${r}
            done
            [[ -f $c ]] && \
            for g in $(ls $c | egrep -v "tar.gz|gz|zip|tar|${NOW_TIME_T1}|${NOW_TIME_T2}|${hulv}" | egrep "log$");do 
                wlog "gzip ${g}"
                #gzip ${g}
            done
        fi
    done
}

clean_applogs(){
    applogs="$BASE_DIR/logs"
    if [[ -d ${applogs} ]];then
       for l in $(ls ${applogs}/*/. -d|egrep 'live|service|server');do
          recursion $l
       done
    fi
}

clean_items(){
    itemslogs="logs"
    for i in $(ls ${BASE_DIR}/*-*/. -d|egrep -v 'delete|logs|project|bak');do
        [[ -d "$i/${itemslogs}" ]] && recursion $i/${itemslogs} || continue
    done
}

warning
clean_applogs
clean_items
