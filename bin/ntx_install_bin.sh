#!/bin/bash

function usage() {
	cat >&2 <<- EOF
	*********************************************************************
	This tool help you install binary file to remoable media (usb/sd) .

	Usage: ${0} <FileName> <SeekSize> <PromptMsg> [SkipSize]
	
	Where : 

	 FileName : binary file to install .
	 SeekSize : seek size .
	 PromptMsg : prompt message .
	 SkipSize : skip size .

	example:
	 ${0} ./zImage 2048 "install kernel image "
	 ${0} ./redboot 2 "install redboot image" 2
	*********************************************************************
	EOF
}

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
	_skipsz=$5

	if [ -z "$_skipsz" ];then
		_skipsz="0"
	fi

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
			sudo dd if=${_bin_file} of=/dev/${_removeable_devname} bs=512 seek=${_seeksz} skip=${_skipsz}
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



FILE_NAME="${1}"
SEEK_SIZE="${2}"
PROMPT_MSG="${3}"
SKIP_SIZE="${4}"

if [ -z "${FILE_NAME}" ];then
	usage
	exit 1
fi

if [ -z "${SEEK_SIZE}" ];then
	usage
	exit 1
fi

if [ -z "${SKIP_SIZE}" ];then
	usage
	exit 1
fi

if [ -z "${PROMPT_MSG}" ];then
	usage
	exit 1
fi


#testmode=1
if [ "${RMEDIA}" = "" ];then
	echo "removeable device not exist !"
	exit 1
else
	install_bin "${FILE_NAME}" ${RMEDIA} ${SEEK_SIZE} "${PROMPT_MSG}" ${SKIP_SIZE}
fi

exit 0

