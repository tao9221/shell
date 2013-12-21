header() {
echo -n " \
rrdtool create /var/www/html/node/$namerrd.rrd \
--start $(date -d "1 year ago" +%s) \
--step 300 \
"
}
base() {
echo -n " \
DS:53:GAUGE:600:U:U \
DS:sl:GAUGE:600:U:U \
DS:cc:GAUGE:600:U:U \
DS:df:GAUGE:600:U:U \
DS:cpu:GAUGE:600:U:U \
DS:mem:GAUGE:600:U:U \
DS:pingloss:GAUGE:600:U:U \
DS:80:GAUGE:600:U:U \
"
}
all() {
echo -n " \
RRA:AVERAGE:0.5:1:600 \
RRA:AVERAGE:0.5:6:700 \
RRA:AVERAGE:0.5:24:775 \
RRA:AVERAGE:0.5:288:797 \
RRA:MAX:0.5:1:600 \
RRA:MAX:0.5:6:700 \
RRA:MAX:0.5:24:775 \
RRA:MAX:0.5:444:797 \
RRA:MIN:0.5:1:600 \
RRA:MIN:0.5:6:700 \
RRA:MIN:0.5:24:775 \
RRA:MIN:0.5:444:797
"
}
fc() {
echo -n " \
DS:rt:GAUGE:600:U:U \
DS:fclogsize:GAUGE:600:U:U \
DS:fclogcount:GAUGE:600:U:U \
DS:ob:GAUGE:600:U:U \
DS:swap50m:GAUGE:600:U:U \
"
}
fscs() {
echo -n " \
DS:rt:GAUGE:600:U:U \
DS:fscslogsize:GAUGE:600:U:U \
"
}
fdns() {
echo -n " \
DS:8030:GAUGE:600:U:U \
"
}
BOND() {
rrdtool create /var/www/html/node/$namerrd.inout.rrd \
--start $(date -d "1 year ago" +%s) \
--step 300 \
DS:in:COUNTER:600:U:U \
DS:out:COUNTER:600:U:U \
$(all)
}
CPISFC() {
$(header) \
$(base) \
$(fc) \
$(all) \
$(BOND)
}
CPISFSCS() {
echo -n " \
$(header) \
$(base) \
$(fscs) \
$(all) \
$(BOND)
"
}
CPISFDNS() {
echo -n " \
$(header) \
$(base) \
$(fdns) \
$(all) \
$(BOND)
"
}

cat $1 | while read line;do
                   serapp=$(echo $line|awk '{print $2}')
                   namerrd=$(echo $line|awk '{print $1}').${serapp} 
                   [[ $serapp == CPISFC ]] && $(CPISFC)
                   [[ $serapp == CPISFSCS ]] && $(CPISFSCS)
                   [[ $serapp == CPISFDNS ]] && $(CPISFDNS)
done
