#!/bin/bash

function relpath_to_abspath() {
	if [ "$(echo $1|grep ^\/)" ];then
		echo "$1"
	elif [ "$(echo $1|grep ^\.)" ];then
		echo "$(pwd)/$(echo $1|sed -s "s/^\.\///g")"
	else
		echo "$(pwd)/$1"
	fi
	return 0
}

SHELLLIB_PATH="$(dirname "$(relpath_to_abspath $0)")"
. "${SHELLLIB_PATH}/rmediafunc.sh"


RMEDIA="$(get_last_removeable_media)"


function install_bin() {
	_bin_file=$1
	_removeable_devname=$2
	_seeksz=$3
	_prompt_msg=$4


	if [ "${_bin_file}" = "" ];then
		read -p "Please input boot image path : " ${_bin_file}
	fi

	#testmode=1
	if [ "${_removeable_devname}" = "" ];then
		echo "removeable device not exist !"
		exit 1
	else
		if [ -f "${_bin_file}" ];then
			echo "${_prompt_msg} \"${_bin_file}\" into /dev/${_removeable_devname} ..."
			sudo dd if=${_bin_file} of=/dev/${_removeable_devname} bs=512 seek=${_seeksz}  
			sudo sync
			sudo sync
			sudo sync
			echo "[done]"
		else
			echo "${_bin_file} not exist !"
		fi
	fi

	return 0

}



#testmode=1
if [ "${RMEDIA}" = "" ];then
	echo "removeable device not exist !"
	exit 1
else
	install_bin "$1" ${RMEDIA} 1024 "install hwconfig code "
fi

exit 0

