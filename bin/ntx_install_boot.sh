#!/bin/bash

function relpath_to_abspath() {
	if [ "$(echo $1|grep ^\/)" ];then
		echo "$1"
	elif [ "$(echo $1|grep ^\.)" ];then
		echo "$(pwd)/$(echo $1|sed -s "s/^\.\///g")"
	else
		echo "$(pwd)/$1"
	fi
}

SHELLLIB_PATH="$(dirname "$(relpath_to_abspath $0)")"
. "${SHELLLIB_PATH}/rmediafunc.sh"


RMEDIA="$(get_last_removeable_media)"

BIMAGE=""
if [ "$1" ];then
	BIMAGE="$1"
else
	BIMAGE="install/bin/redboot.bin"
fi

if [ "${BIMAGE}" = "" ];then
	read -p "Please input boot image path : " BIMAGE
fi

#testmode=1
if [ "${RMEDIA}" = "" ];then
	echo "removeable device not exist !"
	exit 1
else
	if [ -f "${BIMAGE}" ];then
		echo "install boot image \"${BIMAGE}\" into /dev/${RMEDIA} ..."
		sudo dd if=${BIMAGE} of=/dev/${RMEDIA} bs=512 seek=2 skip=2 
		sudo sync
		sudo sync
		sudo sync
		echo "[done]"
	else
		echo "${BIMAGE} not exist !"
	fi
fi

exit 0


