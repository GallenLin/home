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

function install_bin() {
	_dev_node="$1"
	_filename="$2"
	_offset_secs="$3"
	_is_write_bin_info="$4"

	echo "### install ${_filename} in /dev/$_dev_node sector no=${_offset_secs} ... "

	sudo dd if="${_filename}" of="/dev/$_dev_node" bs=512 seek=$_offset_secs;sync

	if [ "$_is_write_bin_info" == "1" ];then

		_bin_size="$(ls -l -L "${_filename}"|awk '{print $5}')"

		_seek_size="$(expr $_offset_secs \* 512 - 16)"
		echo "write bin signature @ $_seek_size bytes in sd ..."
		sudo ${SHELLLIB_PATH}/filemodify-x86 -b 10 -s ${_seek_size} -t buf "/dev/$_dev_node" fff5afff

		_seek_size="$(expr $_seek_size + 4)"
		echo "write bin info swap pattern @ $_seek_size bytes in sd ..."
		sudo ${SHELLLIB_PATH}/filemodify-x86 -s $(printf %x ${_seek_size}) -t dw "/dev/$_dev_node" 12345678

		_seek_size="$(expr $_seek_size + 4)"
		echo "write bin size $_bin_size @ $_seek_size bytes in sd ..."
		sudo ${SHELLLIB_PATH}/filemodify-x86 -b 10 -s ${_seek_size} -t dw "/dev/$_dev_node" $_bin_size

		sync
	fi
	

	return $?
}




SHELLLIB_PATH="$(dirname "$(relpath_to_abspath $0)")"
. "${SHELLLIB_PATH}/rmediafunc.sh"


RMEDIA=$(get_last_removeable_media)

KIMAGE=""
if [ "$1" ];then
	KIMAGE="$1"
else
	KIMAGE="arch/arm/boot/zImage"
fi

KIMG_SECS_OFFSET="2048"

#testmode=1
if [ "${RMEDIA}" = "" ];then
	echo "removeable device not exist !"
	exit 1 
else
	if [ -f ${KIMAGE} ];then
		echo "install kernel image \"${KIMAGE}\" into /dev/${RMEDIA} ..."
		install_bin "$RMEDIA" "$KIMAGE" "$KIMG_SECS_OFFSET" "1"		
		sudo sync
		sudo sync
		sudo sync
		echo "[done]"
	else
		echo "${KIMAGE} not exist !"
	fi
fi

exit 0

