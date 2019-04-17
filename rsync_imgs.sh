watch_dir="/tmp/uploads/"
leng=${#watch_dir}
dst='1.1.1.1::web2'
user='www'

inotifywait -mrq   --format '%w%f' -e close_write --exclude "/\..*|\.filter|\.exclude|\.git" $watch_dir|while read line;do
    #file=`echo ${line##*/}`
    echo "[`date +%F_%H:%M:%S`] $line start rsync"
    op=${line:leng}
    t=`grep $op $watch_dir/.exclude|wc -l`
    if (($t))
    then
        echo "$(date +%F_%T) 文件不同步" >>/tmp/rsync.log 2>&1
    else
        echo $op > $watch_dir.filter
        rsync -auzq --exclude "attachment" --password-file=/etc/rsyncd.passwd.local $watch_dir.filter $user@$dst/.exclude
        rsync -auzq --exclude "attachment" --password-file=/etc/rsyncd.passwd.local --exclude-from=$watch_dir.exclude $watch_dir$op $user@$dst
        echo > $watch_dir.filter && echo "$(date +%F_%T) .filter 文件重置" >>/tmp/rsync.log 2>&1
        rsync -auzq --exclude "attachment" --password-file=/etc/rsyncd.passwd.local $watch_dir.filter $user@$dst/.exclude
    fi
done

