#!/bin/bash
EXTEND=`fdisk -l /dev/sda |egrep  Extend|awk '{print $1}'|awk -F "sda" '{print $2}'`
partprobe
mk6disk()
{
mkdir -p /data/cache{1,2,3,4,5,6} && mkdir -p /data/proclog
VSIZE=112400
fdisk /dev/sdb >/dev/null 2>&1 <<EOF
n
p
2

+${VSIZE}M
n
p
1


w
EOF
for i in c d e f
do
fdisk /dev/sd$i >/dev/null 2>&1 <<EOF
n
p
1


w
EOF
done

partprobe
grep -q "sdb2" /etc/fstab || echo "/dev/sdb2               /data/proclog            ext3    defaults        0 0" >>/etc/fstab
i=1
for x in a b c d e f
do
  if test "$x" == "a";then
    if test -z "$EXTEND";then
      diskp=4
      if test -z "`df -h |grep sda${diskp}`";then
        if test -z "`ls /dev/sda*|grep sda${diskp}`";then
          fdisk /dev/sda >/dev/null 2>&1 <<EOF
n
p


w
EOF
partprobe
sleep 5
          mkfs.ext3 -q /dev/sda${diskp} &
          echo "/dev/sda${diskp}       		/data/cache${i}      		ext3    defaults        0 0" >>/etc/fstab                           
	  echo -e "\033[40;32m format sd${x} ok \033[40;37m"
	else
          mkfs.ext3 -q /dev/sda${diskp} &
          grep -q "/data/cache${i}" /etc/fstab ||echo "/dev/sda${diskp}                /data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi
      fi    
    fi
    if test ! -z "$EXTEND";then
      diskp=$((${EXTEND}+1))
      if test -z "`df -h |grep sda${diskp}`"; then
        if test -z "`ls /dev/sda*|grep sda${diskp}`";then
          fdisk /dev/sda >/dev/null 2>&1 <<EOF
n


w         
EOF
partprobe
sleep 5
          mkfs.ext3 -q /dev/sda${diskp} &
          echo "/dev/sda${diskp}       		/data/cache${i}      		ext3    defaults        0 0" >>/etc/fstab
	  echo -e "\033[40;32m format sd${x} ok \033[40;37m"
	else
	  mkfs.ext3 -q /dev/sda${diskp} &
	  grep -q "/data/cache${i}" /etc/fstab ||echo "/dev/sda${diskp}                /data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi            
      fi    
    fi
        else
        echo -e "formating sd${x}"
        grep -q "sd${x}1" /etc/fstab || test -b /dev/sd${x}1 && mkfs.ext3 -q /dev/sd${x}1 &
        grep -q "sd${x}2" /etc/fstab || test -b /dev/sd${x}2 && mkfs.ext3 -q /dev/sd${x}2 &
        echo -e "\033[40;32m format sd${x} ok \033[40;37m"
 grep -q "sd${x}1" /etc/fstab || echo "/dev/sd${x}1       	/data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi
        (( i++ ))
done

echo -n "Format the Disk now !  Please wait."
while : ;do
        pidof mkfs.ext3 >/dev/null 2>&1
        if [ $? -eq 0 ];then
          sleep 5&& echo  -n "."
        else
          echo -ne "\n  \033[40;32m All disk format completed! \033[40;37m \n"
          break
        fi
done


mount -a
}

mk12disk()
{
mkdir -p /data/cache{1,2,3,4,5,6,7,8,9,10,11,12} && mkdir -p /data/proclog
VSIZE=112400
fdisk /dev/sdb >/dev/null 2>&1 <<EOF
n
p
2

+${VSIZE}M
n
p
1


w
EOF
for i in c d e f g h i j k l
do
fdisk /dev/sd$i >/dev/null 2>&1 <<EOF
n
p
1


w
EOF
done

partprobe
grep -q "sdb2" /etc/fstab || echo "/dev/sdb2               /data/proclog            ext3    defaults        0 0" >>/etc/fstab
i=1
for x in a b c d e f g h i j k l
do
  if test "$x" == "a";then
    if test -z "$EXTEND";then
      diskp=4
      if test -z "`df -h |grep sda${diskp}`";then
        if test -z "`ls /dev/sda*|grep sda${diskp}`";then
          fdisk /dev/sda >/dev/null 2>&1 <<EOF
n
p


w
EOF
partprobe
sleep 5
          mkfs.ext3 -q /dev/sda${diskp} &
          echo "/dev/sda${diskp}       		/data/cache${i}      		ext3    defaults        0 0" >>/etc/fstab
	  echo -e "\033[40;32m format sd${x} ok \033[40;37m"
	else
          mkfs.ext3 -q /dev/sda${diskp} &
          grep -q "/data/cache${i}" /etc/fstab ||echo "/dev/sda${diskp}                /data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi
      fi
    fi
    if test ! -z "$EXTEND";then
      diskp=$((${EXTEND}+1))
      if test -z "`df -h |grep sda${diskp}`"; then
        if test -z "`ls /dev/sda*|grep sda${diskp}`";then
          fdisk /dev/sda >/dev/null 2>&1 <<EOF
n


w         
EOF
partprobe
sleep 5
          mkfs.ext3 -q /dev/sda${diskp} &
          echo "/dev/sda${diskp}       		/data/cache${i}		      	ext3    defaults        0 0" >>/etc/fstab
	  echo -e "\033[40;32m format sd${x} ok \033[40;37m"
	else
          mkfs.ext3 -q /dev/sda${diskp} &
          grep -q "/data/cache${i}" /etc/fstab ||echo "/dev/sda${diskp}                /data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi            
      fi    
    fi
        else
         echo -e "formating sd${x}"
         grep -q "sd${x}1" /etc/fstab || test -b /dev/sd${x}1 && mkfs.ext3 -q /dev/sd${x}1 &
         grep -q "sd${x}2" /etc/fstab || test -b /dev/sd${x}2 && mkfs.ext3 -q /dev/sd${x}2 &
         echo -e "\033[40;32m format sd${x} ok \033[40;37m"
         grep -q "sd${x}1" /etc/fstab || echo "/dev/sd${x}1               /data/cache${i}            ext3    defaults        0 0" >>/etc/fstab
fi
        (( i++ ))
done
echo -n "Format the Disk now !  Please wait."
while : ;do
	pidof mkfs.ext3 >/dev/null 2>&1
	if [ $? -eq 0 ];then
	  sleep 5&& echo  -n "."
	else
	  echo -ne "\n  \033[40;32m All disk format completed! \033[40;37m \n"
	  break
	fi
done


mount -a
}
mk2disk()
{
mkdir -p /data/cache{1,2} && mkdir -p /data/proclog
VSIZE=112400
fdisk /dev/sdb >/dev/null 2>&1 <<EOF
n
p
2

+${VSIZE}M
n
p
1


w
EOF

partprobe
grep -q "sdb2" /etc/fstab || echo "/dev/sdb2               /data/proclog            ext3    defaults        0 0" >>/etc/fstab
i=1
for x in a b
do
  if test "$x" == "a";then
    if test -z "$EXTEND";then
      diskp=4
      if test -z "`df -h |grep sda${diskp}`";then
        if test -z "`ls /dev/sda*|grep sda${diskp}`";then
          fdisk /dev/sda >/dev/null 2>&1 <<EOF
n
p


w
EOF
partprobe
sleep 5
          mkfs.ext3 -q /dev/sda${diskp} &
          echo "/dev/sda${diskp}       	/data/cache${i}		      ext3    defaults        0 0" >>/etc/fstab                           
          echo -e "\033[40;32m format sd${x} ok \033[40;37m"
	else
          mkfs.ext3 -q /dev/sda${diskp} &
          grep -q "/data/cache${i}" /etc/fstab ||echo "/dev/sda${diskp}		/data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi
      fi    
    fi
    if test ! -z "$EXTEND";then
      diskp=$((${EXTEND}+1))
      if test -z "`df -h |grep sda${diskp}`"; then
        if test -z "`ls /dev/sda*|grep sda${diskp}`";then
          fdisk /dev/sda >/dev/null 2>&1 <<EOF
n


w         
EOF
partprobe
sleep 5
          mkfs.ext3 -q /dev/sda${diskp} &
          echo "/dev/sda${diskp}       	/data/cache${i}		      ext3    defaults        0 0" >>/etc/fstab
          echo -e "\033[40;32m format sd${x} ok \033[40;37m"
	else
          mkfs.ext3 -q /dev/sda${diskp} &
          grep -q "/data/cache${i}" /etc/fstab ||echo "/dev/sda${diskp}		/data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi            
      fi    
    fi
        else
        echo -e "formating sd${x}"
	partprobe
	sleep 5
        test -b /dev/sd${x}1 && mkfs.ext3 -q /dev/sd${x}1 &
        test -b /dev/sd${x}2 && mkfs.ext3 -q /dev/sd${x}2 &
        echo -e "\033[40;32m format sd${x} ok \033[40;37m"
 grep -q "sd${x}1" /etc/fstab || echo "/dev/sd${x}1       	/data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi
        (( i++ ))
done

echo -n "Format the Disk now !  Please wait."
while : ;do
        pidof mkfs.ext3 >/dev/null 2>&1
        if [ $? -eq 0 ];then
          sleep 5&& echo  -n "."
        else
          echo -en "\n  \033[40;32m All disk format completed! \033[40;37m \n"
          break
        fi
done


mount -a
}

mk13disk()
{
mkdir -p /data/cache{1,2,3,4,5,6,7,8,9,10,11,12} && mkdir -p /data/proclog
VSIZE=112400
fdisk /dev/sdb >/dev/null 2>&1 <<EOF
n
p
2

+${VSIZE}M
n
p
1


w
EOF
for i in c d e f g h i j k l m
do
fdisk /dev/sd$i >/dev/null 2>&1 <<EOF
n
p
1


w
EOF
done

partprobe
grep -q "sdb2" /etc/fstab || echo "/dev/sdb2               /data/proclog            ext3    defaults        0 0" >>/etc/fstab
i=1
for x in  b c d e f g h i j k l m
do
  if test "$x" == "a";then
    if test -z "$EXTEND";then
      diskp=4
      if test -z "`df -h |grep sda${diskp}`";then
        if test -z "`ls /dev/sda*|grep sda${diskp}`";then
          fdisk /dev/sda >/dev/null 2>&1 <<EOF
n
p


w
EOF
partprobe
sleep 5
          mkfs.ext3 -q /dev/sda${diskp} &
          echo "/dev/sda${diskp}                /data/cache${i}                 ext3    defaults        0 0" >>/etc/fstab
          echo -e "\033[40;32m format sd${x} ok \033[40;37m"
        else
          mkfs.ext3 -q /dev/sda${diskp} &
          grep -q "/data/cache${i}" /etc/fstab ||echo "/dev/sda${diskp}                /data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi
      fi
    fi
    if test ! -z "$EXTEND";then
      diskp=$((${EXTEND}+1))
      if test -z "`df -h |grep sda${diskp}`"; then
        if test -z "`ls /dev/sda*|grep sda${diskp}`";then
          fdisk /dev/sda >/dev/null 2>&1 <<EOF
n


w         
EOF
partprobe
sleep 5
          mkfs.ext3 -q /dev/sda${diskp} &
          echo "/dev/sda${diskp}                /data/cache${i}                 ext3    defaults        0 0" >>/etc/fstab
          echo -e "\033[40;32m format sd${x} ok \033[40;37m"
        else
          mkfs.ext3 -q /dev/sda${diskp} &
          grep -q "/data/cache${i}" /etc/fstab ||echo "/dev/sda${diskp}                /data/cache${i}      ext3    defaults        0 0" >>/etc/fstab
        fi            
      fi    
    fi
        else
         echo -e "formating sd${x}"
         grep -q "sd${x}1" /etc/fstab || test -b /dev/sd${x}1 && mkfs.ext3 -q /dev/sd${x}1 &
         grep -q "sd${x}2" /etc/fstab || test -b /dev/sd${x}2 && mkfs.ext3 -q /dev/sd${x}2 &
         echo -e "\033[40;32m format sd${x} ok \033[40;37m"
         grep -q "sd${x}1" /etc/fstab || echo "/dev/sd${x}1               /data/cache${i}            ext3    defaults        0 0" >>/etc/fstab
fi
        (( i++ ))
done
echo -n "Format the Disk now !  Please wait."
while : ;do
        pidof mkfs.ext3 >/dev/null 2>&1
        if [ $? -eq 0 ];then
          sleep 5&& echo  -n "."
        else
          echo -ne "\n  \033[40;32m All disk format completed! \033[40;37m \n"
          break
        fi
done


mount -a
}

if test -z "$1";then
  echo "Must have parameter 2 or 6 or 12 or 13" 
  else
  if test "$1" -eq "6";then
        mk6disk
    else
    if test "$1" -eq "12";then
      mk12disk
      else
      if test "$1" -eq "2";then
	mk2disk
	else
	if test "$1" -eq "13";then
	mk13disk
	else
		echo "The parameter error! 6 or 12 or 2 or 13"
        	exit 1
	fi
      fi
    fi
  fi
fi
