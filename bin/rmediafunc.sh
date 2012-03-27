#!/bin/bash

#
# purpose :
# 	removeable media library for bash shell .
# author : Gallen Lin @ NEtronix 
# version : 0.1.7 
# Date : 2010/09/03
#


#testmode="1"
function relpath_to_abspath() {
	_pwd="$(pwd)"
	_curfoldername="$(echo $_pwd|sed -e "s/^\/.*\///")"
	if [ "$(echo $1|grep ^\/)" ];then
		echo "$1"
	elif [ "$(echo $1|grep ^\.\.\/)" ];then
		echo "$(echo $_pwd|sed -e "s/\/${_curfoldername}//")/$(echo $1|sed -s "s/^\.\.\///g")"
	elif [ "$(echo $1|grep ^\.\/)" ];then
		echo "$_pwd/$(echo $1|sed -s "s/^\.\///g")"
	else
		echo "$(pwd)/$1"
	fi
}

function docmd() {
	_ret=0
	if [ "$testmode" = "1" ];then
		echo $@
	else
		$@
		_ret=$?
	fi
	return $_ret
}


#################################################
# is_remoeable_media 
# usage :
# 	is_removeable_media [device name]
#			device name : eg, sdc, sdd, ...		
# if print out is "1" is success .
#################################################
function is_removeable_media() {
	RMEDIA=$1

	if [ -f "/sys/block/${RMEDIA}/removable" ];then
		if [ "$(cat "/sys/block/${RMEDIA}/size")" -gt "0" ];then

			if [ "$(cat "/sys/block/${RMEDIA}/dev"|grep "^7:")" ];then
				# loop device driver .
				echo "1"
				return 0
			else
				cat "/sys/block/${RMEDIA}/removable"
				return 0
			fi

		else
			echo "No card in \"${RMEDIA}\" !!"
			return 1
		fi
	else 
		echo "Block device \"${RMEDIA}\" not exist !!"
		return 1
	fi
}




function get_last_removeable_media() {
	_REMOVEABLE_DEV=""

	BLKDEVS_LSTFILE="/tmp/blklst-${USER}"

	ls /sys/block | grep sd > ${BLKDEVS_LSTFILE}

 	for _ND in $(sort -r ${BLKDEVS_LSTFILE});do
		isrm=$(is_removeable_media ${_ND})
		if [ "${isrm}" = "1" ] ;then
			_REMOVEABLE_DEV="${_ND}"
			break
		fi
 	done

	echo -n ${_REMOVEABLE_DEV}
	
	if [ "${_REMOVEABLE_DEV}" ];then
		return 0
	else
		return 1
	fi
}

###########################################
# umount_removeable_media 
# purpose : to umount removeable media
# usage : 
#		umount_removeable_media [device name]
#			device name : eg, sdc , sdd , ... 
#				if this field empty ,it will get the last removeable media .
#	
###########################################
function umount_removeable_media() {
	_ret=0

	if [ "$1" ];then
		_REMOVEABLE_DEV="$1"
	else 
		_REMOVEABLE_DEV="$(get_last_removeable_media)"
	fi


	if [ "$(is_removeable_media ${_REMOVEABLE_DEV})" = "1" ];then
		if [ -d "/sys/block/${_REMOVEABLE_DEV}" ];then
			for ND in $(ls /sys/block/${_REMOVEABLE_DEV} | grep ${_REMOVEABLE_DEV}) 
			do
				docmd sudo umount "/dev/$ND"
			done
		else
			echo "system folder \"/sys/block/${_REMOVEABLE_DEV}\" not exist !!! please check !"
		fi
	else 
		echo "${_REMOVEABLE_DEV} not removeable media !!!"
	fi
	
	return $_ret

}

function mount_removeable_media() {
	_ret=0
	
	if [ "$1" ];then
		_REMOVEABLE_DEV="$1"
	else 
		_REMOVEABLE_DEV="$(get_last_removeable_media)"
	fi

	RMMNTPTLST="/tmp/rmedia_mount_pt_lst-${USER}"
	echo -n "" > ${RMMNTPTLST}

	

	if [ "$(is_removeable_media ${_REMOVEABLE_DEV})" = "1" ];then
		if [ -d "/sys/block/${_REMOVEABLE_DEV}" ];then

			BLKDEVS_LSTFILE="/tmp/blkplst-${USER}"
			ls "/sys/block/${_REMOVEABLE_DEV}" | grep "${_REMOVEABLE_DEV}" > "${BLKDEVS_LSTFILE}"

			for ND in $(sort "${BLKDEVS_LSTFILE}")
			do
				if [ "$(mount|grep "\/media\/${ND}")" ];then
					# mounted already ...
					echo -n "" 
				else	
					if [ -d "/media/${ND}" ];then
						echo -n ""
					else
						sudo mkdir -p "/media/${ND}"
					fi

					if [ "$(sudo blkid|grep "${ND}"|grep "vfat")" ];then
						_is_vfat="1"
					else 
						_is_vfat="0"
					fi

					if [ "${_is_vfat}" == "1" ];then
						#docmd sudo mount -o iocharset=cp950,codepage=950,shortname=winnt,uid=${USER} "/dev/${ND}" "/media/${ND}"
						docmd sudo mount -o users,iocharset=utf8,uid=${USER} "/dev/${ND}" "/media/${ND}"
						#docmd sudo mount -o "users,gid=${USER},uid=${USER},shortname=mixed,dmask=0077,utf8=1,flush" "/dev/${ND}" "/media/${ND}"
					else
						docmd sudo mount -o users "/dev/${ND}" "/media/${ND}"
					fi

				fi
				echo "/media/${ND}" >> "${RMMNTPTLST}"
			done
			cat ${RMMNTPTLST}
		else
			echo "system folder \"/sys/block/${_REMOVEABLE_DEV}\" not exist !!! please check !"
		fi
	else 
		echo "${_REMOVEABLE_DEV} not removeable media !!!"
	fi
	
	return $_ret
}


function create_disk_image() {
	_disk_image="$1"
	_disk_MB="$2"
	_tmplistfile="/tmp/lpimg$(date +%Y%m%d_%H%M%S).lst"
	_tmpprtlistfile="/tmp/prt$(date +%Y%m%d_%H%M%S).lst"
	_tmptypelistfile="/tmp/ptype$(date +%Y%m%d_%H%M%S).lst"

	echo -n "" > "${_tmplistfile}"
	echo -n "" > "${_tmpprtlistfile}"
	echo -n "" > "${_tmptypelistfile}"

	
	echo -n "creating \"${_disk_image}\",${_disk_MB} MB ... "
	sudo dd if=/dev/zero of="${_disk_image}" bs=1M count=${_disk_MB} && sync
	[ $? != 0 ] && echo "[create image fail]" && return 1

	sudo chown ${USER}:${USER} "${_disk_image}"

	_lpdev_free="$(sudo losetup -f)"
	[ -z "${_lpdev_free}" ] && echo "[without free loop dev]" && return 2

	_lpdev_root="${_lpdev_free}"
	sudo losetup "${_lpdev_root}" "${_disk_image}"
	echo "[${_lpdev_root}]"

	read -p "Do you want to fdisk \"${_disk_image}\" [Y/N] :" YN
	if [ -z "$YN" ] || [ "$YN" = "Y" ] || [ "$YN" = "y" ];then
		sudo fdisk -u "${_lpdev_root}"
	fi

	read -p "Do you want to format \"${_disk_image}\" [Y/N] :" YN
	if [ -z "$YN" ] || [ "$YN" = "Y" ] || [ "$YN" = "y" ];then
		sudo fdisk -lu "${_lpdev_root}" |grep "^${_lpdev_root}" > "${_tmplistfile}"
		if [ -z "$(cat "${_tmplistfile}")" ];then
			# no any partition infomation disk withou MBR.
			read -p "Enter your FSTYPE @ \"${_lpdev_root}\": " FSTYPE
			sudo mkfs.${FSTYPE} "${_lpdev_root}"
			sync
		else
			# disk with MBR ...
			while read _lpdev_partition_line 
			do
				_lpdev_pname="$(echo ${_lpdev_partition_line}|awk '{print $1}')"
				echo -n "${_lpdev_pname} " >> "${_tmpprtlistfile}"
			done < "${_tmplistfile}"

			for _lpdev_part in $(cat "${_tmpprtlistfile}")
			do
				read -p "Enter your FSTYPE @ \"${_lpdev_part}\" :" FSTYPE
				echo -n "${FSTYPE} " >> "${_tmptypelistfile}"
			done

			while read _lpdev_partition_line 
			do
				_lpdev_pname="$(echo ${_lpdev_partition_line}|awk '{print $1}'|sed -e "s/\/dev\///")"
				_lpdev_mntpt="/media/${_lpdev_pname}"
				_lpdev_start_sec="$(echo ${_lpdev_partition_line}|awk '{print $2}')"
				_lpdev_end_sec="$(echo ${_lpdev_partition_line}|awk '{print $3}')"
				_lpdev_part_type="$(echo ${_lpdev_partition_line}|awk '{print $5}')"
				_lpdev_total_sec="$(expr ${_lpdev_end_sec} - ${_lpdev_start_sec})"
				_lpdev_free="$(sudo losetup -f)"
				sudo losetup -o $(expr 512 \* $_lpdev_start_sec) --sizelimit $(expr 512 \* $_lpdev_total_sec) "${_lpdev_free}" "${_disk_image}"
				
				FSTYPE=$(cat "${_tmptypelistfile}" |awk '{printf $1}')
				sed -i "s/^${FSTYPE} //" "${_tmptypelistfile}"
				sudo mkfs.${FSTYPE} "${_lpdev_free}"
				sync
				sudo losetup -d "${_lpdev_free}"
			done < "${_tmplistfile}"
		fi
	fi
	
	sudo losetup -d "${_lpdev_root}"
	rm -f "${_tmplistfile}"	>& /dev/null
	rm -f "${_tmpprtlistfile}"	>& /dev/null
	rm -f "${_tmptypelistfile}"	>& /dev/null
	return 0
}


function mount_disk_image() {
	_disk_image="$1"

	if [ -z "${_disk_image}" ];then
		return 1
	fi

	if [ -f "${_disk_image}" ];then
		echo -n ""
	else
		echo "\"${_disk_image}\" do not exist !!"
		return 2
	fi

	_tmplistfile="/tmp/lp$(date +%Y%m%d_%H%M%S).lst"

	_lpdev="$(sudo losetup -f)"
	sudo losetup "${_lpdev}" "${_disk_image}"

	sudo fdisk -lu "${_lpdev}" |grep "^${_lpdev}" > "${_tmplistfile}"
	if [ -z "$(cat "${_tmplistfile}")" ];then
		# make a fake partition info just like fdisk -l list .
		_lpdev_size="$(sudo fdisk -lu "${_lpdev}" |grep "^Disk ${_lpdev}:"|awk '{print $5}')"
		_lpdev_end_sec="$(expr ${_lpdev_size} / 512)"
		_lpdev_total_blks="$(expr ${_lpdev_size} / 512 \* 2)"
		#所用裝置 Boot      Start         End      Blocks   Id  System
		#echo "$_lpdev 0 ${_lpdev_end_sec} ${_lpdev_total_blks}+ 83 Linux"
		echo "$_lpdev 0 ${_lpdev_end_sec} ${_lpdev_total_blks}+ 83 Linux" > "${_tmplistfile}"
	fi

	while read _lpdev_partition_line 
	do
	 	# mount each partition ...
		_lpdev_pname="$(echo ${_lpdev_partition_line}|awk '{print $1}'|sed -e "s/\/dev\///")"
		_lpdev_mntpt="/media/${_lpdev_pname}"
		_lpdev_start_sec="$(echo ${_lpdev_partition_line}|awk '{print $2}')"
		_lpdev_end_sec="$(echo ${_lpdev_partition_line}|awk '{print $3}')"
		_lpdev_total_sec="$(expr ${_lpdev_end_sec} - ${_lpdev_start_sec})"
		_vfat_mnt_option=""

		if [ "$(mount|grep "${_lpdev_mntpt}")" ];then
			#echo "${_lpdev_mntpt} mounted already ."
			continue
		fi

		_lpdev_free="$(sudo losetup -f)"
		sudo losetup -o $(expr 512 \* $_lpdev_start_sec) --sizelimit $(expr 512 \* $_lpdev_total_sec) "${_lpdev_free}" "${_disk_image}"
		if [ "$(sudo blkid|grep "${_lpdev_free}"|grep "vfat")" ];then
			_vfat_mnt_option="rw,nosuid,nodev,uid=${USER},gid=${USER},shortname=mixed,umask=0007,utf8=1,flush,iocharset=utf8,"
		fi

		sudo mkdir -p /media/${_lpdev_pname}
		#sudo chown ${USER}:${USER} "/media/${_lpdev_pname}"
		sudo mount -o ${_vfat_mnt_option}users "${_lpdev_free}" "${_lpdev_mntpt}"
		if [ $? = 0 ];then
			echo -n "/media/${_lpdev_pname} "
		else
			sudo losetup -d "${_lpdev_free}"
		fi
	done < "${_tmplistfile}"
	echo ""

	sudo losetup -d "${_lpdev}"
	rm -f "${_tmplistfile}" >& /dev/null
	return 0
}

function umount_disk_image() {
	_disk_image="$1"
	if [ -z "${_disk_image}" ];then
		return 1
	fi

	if [ -f "${_disk_image}" ];then
		echo -n ""
	else
		echo "\"${_disk_image}\" do not exist !!"
		return 2
	fi

	_disk_image_abs="$(relpath_to_abspath "${_disk_image}")"
	_image_abs_lpsearch="$(echo "${_disk_image_abs}"|head -c 62)"

	_tmplistfile="/tmp/lpimg$(date +%Y%m%d_%H%M%S).lst"

	echo -n "" > "${_tmplistfile}"

	for _lpdev in $(ls /dev/loop*)
	do
		_lpdev_info="$(sudo losetup ${_lpdev} 2>/dev/null)"
		if [ "$(echo ${_lpdev_info}|grep "${_image_abs_lpsearch}")" ];then
			#echo "${_lpdev_info}" #>> "${_tmplistfile}"
			_lpdev_node="$(echo "${_lpdev_info}"|awk -F : '{print $1}')"
			echo -n "${_lpdev_node} "
			if [ "$(mount|grep "${_lpdev_node}")" ];then
				sudo umount "${_lpdev_node}"
				sudo losetup -d "${_lpdev_node}"
			fi
		fi
	done

	echo ""

	rm -f "${_tmplistfile}" >& /dev/null
	return 0
}


