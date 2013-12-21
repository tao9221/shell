basewarn() {
      fc53=$(awk '$1=="fc-53"{print $2}' $i);((fc53 != 1 ))      && echo -e "53:${fc53} down" >/root/warn/$name
      fcsl=$(awk '$1=="fc-sl"{print $2}' $i);((fcsl > 9))        && echo -e "sl:${fcsl}" >>/root/warn/$name
      fccc=$(awk '$1=="fc-cc"{print $2}' $i);(( fccc > 30000 ))   && echo -e "cc:${fccc}" >>/root/warn/$name
      fcdf=$(awk '$1=="fc-df"{print $2}' $i);(( fcdf > 85 ))     && echo -e "df:${fcdf}" >>/root/warn/$name
      fccpu=$(awk '$1=="fc-cpu"{print $2}' $i);(( fccpu >= 200 ))&& echo -e "cpu:${fccpu}" >>/root/warn/$name
      fcmem=$(awk '$1=="fc-mem"{print $2}' $i);(( fcmem < 1000 ))&& echo -e "lastmem:${fcmem}" >>/root/warn/$name
      fcping=$(awk '$1=="ping-loss"{print $2}' $i);(( fcping > 15 ))&& echo -e "pingloss:${fcping}" >>/root/warn/$name
      fc80=$(awk '$1=="fc-80"{print $2}' $i);(( fc80 != 1 ))     && echo -e "fc80:${fc80}" >>/root/warn/$name
}

for app in CPISFDNS CPISFSCS CPISFC;do
dirname="/var/www/html/test/rrdnode/*"
node=($(ls $dirname -d| egrep -v "*.inout" | egrep "*.${app}"| xargs -n1000))
nodeinout=($(ls $dirname -d| egrep "*.inout" | egrep "*.${app}" | xargs -n1000))
  for i in ${node[@]};do
      name=$(basename $i)
      nodefile=/var/www/html/node/$name
      input=$(awk '{printf(":%s", $NF)}' $i|cut -d\: -f 2-20)
      rrdtool update $nodefile.rrd N:${input}
#      basewarn
  done
  for j in ${nodeinout[@]};do
      nodefile=/var/www/html/node/$(basename $j)
      input=$(awk '{printf(":%s", $NF)}' $j|cut -d\: -f 2-20)
      rrdtool updatev $nodefile.rrd N:${input}
  done
done
for warn in $(ls /root/warn/*);do
    echo -e "$(basename $warn)" >> warn.mutt
    cat $warn >> warn.mutt
done
[ -f warn.mutt -a -n warn.mutt ] && time=$(date +%F_%T) && cat warn.mutt | mutt -s "$time" 'linuxtao@163.com'
rm -f /root/warn/* warn.mutt
