#!/bin/bash

MNTPT="/media/GALLEN_750GB"
USBHD_UUID="AEA41F64A41F2E79"

#_user=${USER}
_user="www-data"

if [ "$(mount|grep "${MNTPT}")" ];then
	echo "\"${MNTPT}\" mounted already , please umount it first !"
	exit 1
fi

if [ ! -d "${MNTPT}" ];then
	echo "create \"${MNTPT}\""
	sudo mkdir "${MNTPT}"
fi

sudo chown ${_user}:${_user} "${MNTPT}"
sudo chmod g+w ${MNTPT}
echo -n "mount usbdisk uuid=${USBHD_UUID} @ ${MNTPT} ... "
sudo mount -t ntfs -o uid=${_user},gid=${_user},users,umask=0000,sync UUID="${USBHD_UUID}" "${MNTPT}"

[ $? = 0 ] && echo "[done]" && exit 0

echo "[fail]" && exit 1

