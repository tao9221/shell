#/bin/bash
#interdisk.sh
#-------------------------------------------------------------------------|
#   @Program    : cpis_createxml.sh                                       |  
#   @Version    : 1.0.0                                                   |
#   @Company    : ChinaCache                                              |
#   @Dep.       : Guaranteed Application Delivery .GAD                    |
#   @Writer     : YiTian   <juntao.qin@chinacache.com>                    |
#   @Team Leader: qing.chen;Cpis_opt 				          |
#   @Date       : 2013-08-08                                              |
#-------------------------------------------------------------------------|


rm -rf /root/tmps/* && rm -f /root/KUANLIAN-*

dtime=30
filename=($(ls -d /root/node/*))
dirname=/root/tmps
SNMPWALK=/usr/bin/snmpwalk

# multiprocess

num=200
fifo="fifo.tmp"
mkfifo $fifo
exec 3<>$fifo
rm -f $fifo
for((i=1;i<=$num;i++));do echo ;done >&3

for node in ${filename[@]};do
	dirok=$(basename $node)
	test -d ${dirname}/$dirok || mkdir ${dirname}/$dirok
        #[[ $node == "xunlei_eth0" ]] && rm -rf ${dirname}/xunlei_eth0
while read key ip
do
#	bond0=$(/usr/bin/snmpwalk -v 2c -c ${key} ${ip} .1.3.6.1.2.1.2.2.1.2 | awk -F"[. ]+" '{if($NF~/bond0/){print $2}else{ if($NF~/eth0/){print $2}}}' | tail -n1)
#      ((bond0=bond0<1?10:bond0))
read -u 3
{
	bond0=$(/usr/bin/snmpwalk -v 2c -c ${key} ${ip} .1.3.6.1.2.1.2.2.1.2 | awk -F"[. ]+" '{if($NF~/bond0/){print $2}else{ if($NF~/eth0/){print $2}}}' | tail -n1)
      ((bond0=bond0<1?10:bond0))
      if [ $dirok != "xunlei_eth0" -a $dirok != "JSKL-FX" ];then
#      $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} .1.3.6.1.2.1.25.2.3.1 > ${dirname}/${dirok}/${ip}.disk
      for i in IF-MIB::ifHCInOctets.${bond0} IF-MIB::ifHCOutOctets.${bond0};do
          $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} ${i} | awk -v i=${i} '{print "one",i,$NF}' > ${dirname}/${dirok}/${ip}.${i}
          sleep $dtime
          $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} ${i} | awk -v i=${i} '{print "two",i,$NF}' >> ${dirname}/${dirok}/${ip}.${i}
          [[ $(cat ${dirname}/${dirok}/${ip}.${i}|wc -l) != 2 ]] && echo "0"> ${dirname}/${dirok}/${ip}.${i}
      done
      elif [ $dirok == xunlei_eth0 ];then
#      $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} .1.3.6.1.2.1.25.2.3.1 > ${dirname}/JSKL-THUNDER/${ip}.disk
      for eth in IF-MIB::ifHCInOctets.2 IF-MIB::ifHCOutOctets.2;do
          $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} ${eth} | awk -v i=${eth} '{print "one",i,$NF}' > ${dirname}/JSKL-THUNDER/${ip}.${eth}
          sleep $dtime
          $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} ${eth} | awk -v i=${eth} '{print "two",i,$NF}' >> ${dirname}/JSKL-THUNDER/${ip}.${eth}
          [[ $(cat ${dirname}/${dirok}/${ip}.${i}|wc -l) != 2 ]] && echo "0"> ${dirname}/${dirok}/${ip}.${i}
      done
      elif [ $dirok == JSKL-FX ];then
#      $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} .1.3.6.1.2.1.25.2.3.1 > ${dirname}/${dirok}/${ip}.disk
      for kou in 2 3;do
      for eth in IF-MIB::ifHCInOctets.$kou IF-MIB::ifHCOutOctets.$kou;do
          $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} ${eth} | awk -v i=${eth} '{print "one",i,$NF}' > ${dirname}/${dirok}/${ip}.${eth}
          sleep $dtime
          $SNMPWALK -t0.3 -v 2c -c ${key} ${ip} ${eth} | awk -v i=${eth} '{print "two",i,$NF}' >> ${dirname}/${dirok}/${ip}.${eth}
          [[ $(cat ${dirname}/${dirok}/${ip}.${i}|wc -l) != 2 ]] && echo "0"> ${dirname}/${dirok}/${ip}.${i}
      done
      done
      fi
echo >&3

}&

done < ${node}
done
wait
exec 3>&-

for nownode in ${filename[@]};do
	dirnow=$(basename $nownode)
	test -d $dirname/result/${dirnow} || mkdir -p $dirname/result/${dirnow}
        [[ $dirnow == "xunlei_eth0" ]] && rm -rf $dirname/result/xunlei_eth0 && continue

#	diskfile=($(ls /root/tmps/${dirnow}/*.disk))
	infile=($(ls /root/tmps/${dirnow}/*.*ifHCInOctets*))
	outfile=($(ls /root/tmps/${dirnow}/*.*ifHCOutOctets*))

	for disk in ${diskfile[@]};do 
        	hostip=$(echo $(basename $disk) | awk 'BEGIN{FS=".";OFS="."}{print $1,$2,$3,$4}')
        	number=$(awk -F'[. ]+' '$NF~/home/||$NF~/data/||$NF~/media/||$5~/[A-F]/{print $2}' ${disk})
		for i in ${number};do 
  			awk -F'[:. ]+' -v i=${i} '$2~/hrStorageAllocationUnits/ && $3==i{printf("%s %d"," ",$(NF-1))} $2~/hrStorageSize/ && $3==i{printf("%s %d"," ",$NF)} $2~/hrStorageUsed/ && $3==i{print " ",$NF}' ${disk}
		done | awk '{total+=$2;used+=$3}END{printf("%s%d\n%s%d\n", "diskuse:",used*$1/1024/1024/1024,"diskusebi:",total*$1/1024/1024/1024)}' > $dirname/result/${dirnow}/$hostip
	done

	for inter in ${infile[@]};do
        	hostipin=$(echo $(basename $inter) | awk 'BEGIN{FS=".";OFS="."}{print $1,$2,$3,$4}')
    		awk -v dtime=$dtime '{ain=$NF-ain}END{if(ain>0)print "In:",ain*8/1000/dtime,"Kbps/s"}' ${inter} >> $dirname/result/${dirnow}/$hostipin
	done

	for outter in ${outfile[@]};do
        	hostipout=$(echo $(basename $outter) | awk 'BEGIN{FS=".";OFS="."}{print $1,$2,$3,$4}')
        	awk -v dtime=$dtime '{ain=$NF-ain}END{if(ain>0)print "Out:",ain*8/1000/dtime,"Kbps/S"}' ${outter} >> $dirname/result/${dirnow}/$hostipout
	done
	rm -f $dirname/result/${dirnow}/total;cat $dirname/result/${dirnow}/* | awk -F: '$1 == "diskusebi"{diskbi+=$2} $1=="diskuse"{diskuse+=$2} $1~/In/{IN+=$2} $1~/Out/{OUT+=$2}END{printf("%s\n%s\n%s\n%s\n", "DISKZONG:"diskbi,"DISKUSE:"diskuse,"In:"IN,"Out:"OUT)}' >> $dirname/result/${dirnow}/total
done


#creat xml
oktime=$(date "+%Y%m%d-%H%M")
if [[ $(echo ${oktime}|awk -F '' '{print $NF}') > 5 ]];then
  filetime=$(echo ${oktime}|sed -e 's/./5/13') 
else
  filetime=$(echo ${oktime}|sed -e 's/./0/13')
fi
filexml=KUANLIAN-P2P-${filetime}
nowtime=$(date "+%F %T")
name=($(ls /root/tmps/result/* -d))

numbernow=0
   echo -en "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<KPI Provider=\"KL-P2P\">" > ${filexml}

cat /root/tmps/result/*/total | awk -F: '$1~/DISKZONG/{disklv+=$2} $1~/DISKUSE/{diskus+=$2} $1~/In/{IN+=$2} $1~/Out/{OUT+=$2}END{printf("%s\n%s\n%s\n%s\n", "DISKZONG:"disklv,"DISKUSE:"diskus,"In:"IN,"Out:"OUT)}'>totalnow
#totaldiskutil=$(awk -F: '$1~/DISKZONG/{printf("%d", $2)}' totalnow)
#totaldiskuse=$(awk -F: '$1~/DISKUSE/{printf("%d", $2)}' totalnow)
totalFin=$(awk -F: '$1~/In/{printf("%d", $2)}' totalnow)
totalFout=$(awk -F: '$1~/Out/{printf("%d", $2)}' totalnow)
totalcache=$(echo "scale=2;${totalFout}/75000000*100"|bc)
echo -en "<node sequence=\"0\"><CSSprotocol>P2P-Total</CSSprotocol><FlowIn>${totalFin}</FlowIn><FlowOut>${totalFout}</FlowOut><CacheUtil>${totalcache}</CacheUtil><CacheMaxDesignOut>78643200</CacheMaxDesignOut><CreateDate>${nowtime}</CreateDate></node>" >> ${filexml}

for i in ${name[@]};do
   nodeseq=$(((++numbernow)))
   protocol=$(basename $i)
   diskutil=$(awk -F: '$1~/DISKZONG/{printf("%d", $2)}' $i/total)
   diskuse=$(awk -F: '$1~/DISKUSE/{printf("%d", $2)}' $i/total)
   Fin=$(awk -F: '$1~/In/{printf("%d", $2)}' $i/total)
   Fout=$(awk -F: '$1~/Out/{printf("%d", $2)}' $i/total)
   echo -en "<node sequence=\"${nodeseq}\"><CSSprotocol>${protocol}</CSSprotocol><FlowIn>${Fin}</FlowIn><FlowOut>${Fout}</FlowOut><CreateDate>${nowtime}</CreateDate></node>" >> ${filexml}
done
echo -en '</KPI>' >> ${filexml}

#backup
test -d /root/backupxml && cp /root/${filexml} /root/backupxml/${filexml}.$(date +%F) || (mkdir /root/backupxml && cp /root/${filexml} /root/backupxml/${filexml}.$(date +%F))

#ftp put

ftp -v -n  $ip <<EOF
user $user $passwd
binary
hash
cd ~/
lcd /root
prompt
mput $filexml
rename $filexml ${filexml}.xml
bye
EOF
state=`echo $?`
[[ $state != 0 ]] && echo "$name transmission fail!" >>/root/ftp_erorr.log
