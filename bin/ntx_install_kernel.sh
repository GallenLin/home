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


RMEDIA=$(get_last_removeable_media)

KIMAGE=""
if [ "$1" ];then
	KIMAGE="$1"
else
	KIMAGE="rpm/BUILD/linux/arch/arm/boot/zImage"
fi

#testmode=1
if [ "${RMEDIA}" = "" ];then
	echo "removeable device not exist !"
	exit 1 
else
	if [ -f ${KIMAGE} ];then
		echo "install kernel image \"${KIMAGE}\" into /dev/${RMEDIA} ..."
		sudo dd if=${KIMAGE} of=/dev/${RMEDIA} bs=512 seek=2048 
		sudo sync
		sudo sync
		sudo sync
		echo "[done]"
	else
		echo "${KIMAGE} not exist !"
	fi
fi

exit 0

