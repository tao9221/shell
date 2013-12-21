header() {
echo -n " \
rrdtool graph $nodefilename.png -w 1000 -h 400 \
-n TITLE:12:"$ziti" \
-n LEGEND:8:"$ziti" \
--title="${nodem}" -v "All" \
--start -1$sj --end now \
--slope-mode \
--upper-limit 1500 \
--disable-rrdtool-tag \
TEXTALIGN:right \
-Y -X 0 \
"
}
base() {
echo -n " \
DEF:vl1=$nodefile.rrd:53:AVERAGE \
DEF:vl2=$nodefile.rrd:sl:AVERAGE \
DEF:vl3=$nodefile.rrd:cc:AVERAGE \
DEF:vl4=$nodefile.rrd:df:AVERAGE \
DEF:vl5=$nodefile.rrd:cpu:AVERAGE \
DEF:vl6=$nodefile.rrd:mem:AVERAGE \
DEF:vl13=$nodefile.rrd:pingloss:AVERAGE \
DEF:vl7=$nodefile.rrd:80:AVERAGE \
CDEF:l1=vl1,100,- \
CDEF:l2=vl2,200,- \
CDEF:l3=vl3,10,/ \
CDEF:l4=vl4,400,- \
CDEF:l5=vl5,500,- \
CDEF:ll6=vl6,1000,/ \
CDEF:l6=ll6,600,- \
CDEF:l13=vl13,900,- \
CDEF:l7=vl7,400,+ \
COMMENT:"\\n" \
COMMENT:"\\n" \
COMMENT:"\\t\\t\\t----last---------avg---------max---------min-------------*-----------++y\\n" \
COMMENT:"\\n" \
LINE1:l7#8A2BE2:"80\\t\\t" \
GPRINT:vl7:LAST:"%12.2lf"  \
GPRINT:vl7:AVERAGE:"%12.2lf"  \
GPRINT:vl7:MAX:"%12.2lf"  \
GPRINT:vl7:MIN:"%12.2lf\\t\\t0\\t\\t400\\n"  \
LINE1:l1#FF0000:"53\\t\\t" \
GPRINT:vl1:LAST:"%12.2lf"  \
GPRINT:vl1:AVERAGE:"%12.2lf"  \
GPRINT:vl1:MAX:"%12.2lf"  \
GPRINT:vl1:MIN:"%12.2lf\\t\\t0\\t\\t-100\\n"  \
LINE1:l13#666777:"pingloss\\t" \
GPRINT:vl13:LAST:"%12.2lf"  \
GPRINT:vl13:AVERAGE:"%12.2lf"  \
GPRINT:vl13:MAX:"%12.2lf"  \
GPRINT:vl13:MIN:"%12.2lf\\t\\t0\\t\\t-900\\n"  \
LINE1:l4#5C3317:"df\\t\\t" \
GPRINT:vl4:LAST:"%12.2lf"  \
GPRINT:vl4:AVERAGE:"%12.2lf"  \
GPRINT:vl4:MAX:"%12.2lf"  \
GPRINT:vl4:MIN:"%12.2lf\\t\\t0\\t\\t-400\\n"  \
LINE1:l5#B5A642:"cpu\\t\\t" \
GPRINT:vl5:LAST:"%12.2lf"  \
GPRINT:vl5:AVERAGE:"%12.2lf"  \
GPRINT:vl5:MAX:"%12.2lf"  \
GPRINT:vl5:MIN:"%12.2lf\\t\\t0\\t\\t-500\\n"  \
LINE1:l2#00FFFF:"sl\\t\\t" \
GPRINT:vl2:LAST:"%12.2lf"  \
GPRINT:vl2:AVERAGE:"%12.2lf"  \
GPRINT:vl2:MAX:"%12.2lf"  \
GPRINT:vl2:MIN:"%12.2lf\\t\\t0\\t\\t-200\\n"  \
LINE1:l3#FFFF00:"cc\\t\\t" \
GPRINT:vl3:LAST:"%12.2lf"  \
GPRINT:vl3:AVERAGE:"%12.2lf"  \
GPRINT:vl3:MAX:"%12.2lf"  \
GPRINT:vl3:MIN:"%12.2lf\\t\\t0\\t\\t0\\n"  \
LINE1:ll6#A67D3D:"mem\\t\\t" \
GPRINT:ll6:LAST:"%12.2lf"  \
GPRINT:ll6:AVERAGE:"%12.2lf"  \
GPRINT:ll6:MAX:"%12.2lf"  \
GPRINT:ll6:MIN:"%12.2lf\\t\\t0\\t\\t-600\\n"  \
"
}
bottom() {
echo -n " \
DEF:value1=$nodefile.inout.rrd:in:AVERAGE \
DEF:value2=$nodefile.inout.rrd:out:AVERAGE \
CDEF:in=value1,8,* \
CDEF:out=value2,8,* \
CDEF:inx=in,10000,/ \
CDEF:outx=out,10000,/ \
CDEF:ind=in,1000000,/ \
CDEF:outd=out,1000000,/ \
CDEF:ino=in,1000000,GT,ind,inx,IF \
CDEF:outo=out,1000000,GT,outd,outx,IF \
COMMENT:"\\n" \
AREA:outo#00ff00:"out\\t\\t" \
GPRINT:out:LAST:"%10.2lf%s"  \
GPRINT:out:AVERAGE:"%10.2lf%s"  \
GPRINT:out:MAX:"%10.2lf%s"  \
GPRINT:out:MIN:"%10.2lf%s\\t\\t0\\t\\t0\\n"  \
LINE1:ino#4433ff:"in\\t\\t" \
GPRINT:in:LAST:"%10.2lf%s"  \
GPRINT:in:AVERAGE:"%10.2lf%s"  \
GPRINT:in:MAX:"%10.2lf%s"  \
GPRINT:in:MIN:"%10.2lf%s\\t\\t0\\t\\t0\\n"  \
COMMENT:"\\n" \
COMMENT:"\\t\\t\\t-----------------------------------------------------------------------------------\\n" \
COMMENT:"\\n" \
COMMENT:"\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\tlast-update\\t\[$(date '+%Y%m%d\\t%H\:%M')\]" -Y \
COMMENT:"\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\tCPIS-OPT\\toperations\\tdevelopment\\n"
"
}
fc() {
echo -n " \
DEF:vl8=$nodefile.rrd:rt:AVERAGE \
DEF:vl9=$nodefile.rrd:fclogsize:AVERAGE \
DEF:vl10=$nodefile.rrd:fclogcount:AVERAGE \
DEF:vl11=$nodefile.rrd:ob:AVERAGE \
DEF:vl12=$nodefile.rrd:swap50m:AVERAGE \
CDEF:l8=vl8,500,+ \
CDEF:ll9=vl9,1000,/ \
CDEF:l9=ll9,700,+ \
CDEF:l10=vl10,600,+ \
CDEF:ll11=vl11,10000,/ \
CDEF:l11=ll11,700,- \
CDEF:l12=vl12,800,- \
LINE1:l8#DEB887:"rt\\t\\t" \
GPRINT:vl8:LAST:"%12.2lf"  \
GPRINT:vl8:AVERAGE:"%12.2lf"  \
GPRINT:vl8:MAX:"%12.2lf"  \
GPRINT:vl8:MIN:"%14.2lf\\t\\t0\\t\\t500\\n"  \
LINE1:l12#8E2323:"swap50m\\t" \
GPRINT:vl12:LAST:"%12.2lf"  \
GPRINT:vl12:AVERAGE:"%12.2lf"  \
GPRINT:vl12:MAX:"%12.2lf"  \
GPRINT:vl12:MIN:"%12.2lf\\t\\t0\\t\\t-800\\n"  \
LINE1:l10#008B8B:"fclogcount\\t" \
GPRINT:vl10:LAST:"%12.2lf"  \
GPRINT:vl10:AVERAGE:"%12.2lf"  \
GPRINT:vl10:MAX:"%12.2lf"  \
GPRINT:vl10:MIN:"%12.2lf\\t\\t0\\t\\t600\\n"  \
LINE1:l9#000000:"fclogsize\\t" \
GPRINT:ll9:LAST:"%12.2lf"  \
GPRINT:ll9:AVERAGE:"%12.2lf"  \
GPRINT:ll9:MAX:"%8.2lf"  \
GPRINT:ll9:MIN:"%12.2lf\\t\\t/1000\\t700\\n"  \
LINE1:l11#42426F:"ob\\t\\t" \
GPRINT:ll11:LAST:"%12.2lf"  \
GPRINT:ll11:AVERAGE:"%12.2lf"  \
GPRINT:ll11:MAX:"%12.2lf"  \
GPRINT:ll11:MIN:"%12.2lf\\t\\t10*4\\t\\t-700\\n"  \
"
}
fscs() {
echo -n " \
DEF:vl8=$nodefile.rrd:rt:AVERAGE \
DEF:vl9=$nodefile.rrd:fscslogsize:AVERAGE \
CDEF:l8=vl8,500,+ \
CDEF:ll9=vl9,1000,/ \
CDEF:l9=ll9,700,+ \
CDEF:l12=vl8,800,- \
LINE1:l8#DEB887:"rt\\t\\t" \
GPRINT:vl8:LAST:"%12.2lf"  \
GPRINT:vl8:AVERAGE:"%12.2lf"  \
GPRINT:vl8:MAX:"%12.2lf"  \
GPRINT:vl8:MIN:"%14.2lf\\t\\t0\\t\\t500\\n"  \
LINE1:l9#000000:"fclogsize\\t" \
GPRINT:ll9:LAST:"%12.2lf"  \
GPRINT:ll9:AVERAGE:"%12.2lf"  \
GPRINT:ll9:MAX:"%8.2lf"  \
GPRINT:ll9:MIN:"%12.2lf\\t\\t/1000\\t700\\n"  \
"
}
fdns() {
echo -n " \
DEF:vl8=$nodefile.rrd:8030:AVERAGE \
CDEF:l8=vl8,500,+ \
LINE1:l8#DEB887:"8083\\t\\t" \
GPRINT:vl8:LAST:"%12.2lf"  \
GPRINT:vl8:AVERAGE:"%12.2lf"  \
GPRINT:vl8:MAX:"%12.2lf"  \
GPRINT:vl8:MIN:"%14.2lf\\t\\t0\\t\\t500\\n"  \
"
}
CPISFC() {
$(header) \
$(base) \
$(fc) \
$(bottom) 
}
CPISFSCS() {
$(header) \
$(base) \
$(fscs) \
$(bottom)
}
CPISFDNS() {
$(header) \
$(base) \
$(fdns) \
$(bottom)
}
ziti=/var/www/html/ok.ttf

for app in CPISFDNS CPISFSCS CPISFC;do
dirname="/var/www/html/test/rrdnode/*"
node=($(ls $dirname |egrep -v "*.inout"|egrep "*.${app}" |xargs -n1000))
time=$(date '+%Y%m%d %H:%M')
  for i in ${node[@]};do
     for j in d w m y;do
         nodem="$j--nodename:($(basename $i))"
         nodefilename=/var/www/html/node/$(basename $i).$j
         nodefile=/var/www/html/node/$(basename $i)
         sj=$j
	 ${app}
     done
  done
done
