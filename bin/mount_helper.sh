#!/bin/bash

#
# mount helper functions .
# author : Gallen Lin
#

function mount_cifs() {
	_server_ip="$1"
	_server_share_name="$2"
	_mount_point="$3"
	_username="$4"
	_passwd="$5"

	mountpt_check "${_mount_point}"


	if [ "$?" = "1" ];then
		echo "mount from //${_server_ip}/${_server_share_name} to $_mount_point ..."
		if [ "${_username}" ];then
			if [ "${_passwd}" ];then
				sudo mount.cifs //${_server_ip}/${_server_share_name} "$_mount_point" -o ip=${_server_ip},iocharset=utf8,uid=${USER},username=${_username},password=${_passwd}
			else
				sudo mount.cifs //${_server_ip}/${_server_share_name} "$_mount_point" -o ip=${_server_ip},iocharset=utf8,uid=${USER},username=${_username}
			fi
		else 
			sudo mount.cifs //${_server_ip}/${_server_share_name} "$_mount_point" -o ip=${_server_ip},iocharset=utf8,uid=${USER}
		fi
		#sudo chown ${USER}:${USER} ${_mount_point}

  	if [ "$?" = "0" ];then
    	echo "[done]"
  	else
    	echo "[fail]"
			return 1
  	fi
	fi

	return 0
}

#
# mount usb hdd by label name .
# 
#
function mount_usb_hdd_by_label() {
	_label_name="$1"
	_mount_point="$2"
	_mnt_option="$3"


	# to find disk with _label_name ...
	_dev_node="$(sudo blkid|grep "${_label_name}"|awk -F ' ' '{print $1}'|sed -e "s/://")"
	_fs_type="$(sudo blkid|grep "${_label_name}"|awk -F ' ' '{print $4}'|sed -e "s/TYPE=\"//"|sed -e "s/\"//")"
	if [ "${_dev_node}" ];then
		sudo umount ${_dev_node} >& /dev/null

		_mount_opt_str=""
		#_mount_opt_default="iocharset=cp950,codepage=950,shortname=winnt"
		_mount_opt_default="iocharset=utf8"
		if [ "${_mnt_option}" ];then
			_mount_opt_str="-o ${_mount_opt_default},${_mnt_option}"
		else
			_mount_opt_str="-o ${_mount_opt_default}"
		fi

		echo -n "mount ${_fs_type} ${_mount_opt_str} ${_dev_node} @ ${_mount_point} ... "
		sudo mount -t ${_fs_type} ${_mount_opt_str} "${_dev_node}" "${_mount_point}"
		if [ $? == 0 ];then
			echo "[Done]"
		else
			echo "[Fail]"
			return 1
		fi
	else
		echo "usb disk \"${_label_name}\" not found !"
		return 1	
	fi
	return 0

}

function mountpt_check() {
	## mount prepare function : check mount point folder and create it automatically .
	## arguments :
	##	mountpt_check <mount point> 
	## return : 0 -> success ; 1 -> you should do mount action ; others -> fail 

	MNTPT="$1"

	echo -n "checking mount point folder @ \"$MNTPT\"  ......"

	if [ -e "$MNTPT" ];then
		echo " [exist]"
	else
		mkdir -p "$MNTPT"
		echo " [created]"
	fi

	if [ "$(mount|grep "$MNTPT")" ];then
   	echo "\"$MNTPT\" mounted already !"
	else
		return 1
	fi

	return 0
}

