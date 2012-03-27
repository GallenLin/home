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


RMEDIA="$(get_last_removeable_media)"

BIMAGE=""
if [ "$1" ];then
	BIMAGE="$1"
else
	BIMAGE="u-boot.bin"
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
		sudo dd if=${BIMAGE} of=/dev/${RMEDIA} bs=512 seek=256  
		sudo sync
		sudo sync
		sudo sync
		echo "[done]"
	else
		echo "${BIMAGE} not exist !"
	fi
fi

exit 0


