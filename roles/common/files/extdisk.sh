#!/bin/bash
lastpart=`fdisk -l /dev/sda|awk 'END {print $1}'`
lastnumber=${lastpart: -1}
((newnumber=lastnumber+1))
echo -e "n\np\n${newnumber}\n\n\nt\n${newnumber}\n8e\nw\n" | fdisk /dev/sda
partprobe
kpartx /dev/sda${newnumber}
pvcreate /dev/sda${newnumber}
vgextend rhel /dev/sda${newnumber}
lvextend -l +100%FREE /dev/rhel/root
xfs_growfs /dev/mapper/rhel-root
