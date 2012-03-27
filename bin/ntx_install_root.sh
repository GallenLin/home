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



workdir="$(pwd)"

function usage() {
	cat >&2 <<- EOF

	This tool help to install rootfs into removeable media or single tgz file .

	 Usage: ${0} [-v] [-t] [-f] [-I] [-i <package>] [-r <package>] [-o <output tgz path>] <rootfs_from_path>
	
	  rootfs_from_path : the path of rootfs which you want to install .

	Options:
	 -v : show more infomation in processing .
	 -I : ignore document files (eg, man pages) .
	 -o <pathname> : output filesystem into a single <pathname> file in tgz format .
	 -i <package file> : just install the package files that indicated in "package file" (rpm file) into removeable media (if exist).
	   note : if "package file" do not include path ,this program will search "package file" in "./rpm/RPMS/arm"
	 -r <package file> : just remove the package files that indicated in "package file" (rpm file) from removeable media (if exist).
	   note : if "package file" do not include path ,this program will search "package file" in "./rpm/RPMS/arm"
	 -t : run as test mode : it's just show what will do .
	 -f : force overwrite mode : do not clean the target rootfs .

	Example:

	 --> to install "./rootfs" files(except ".svn" folders) into removeable media partition one (if exist) 
	   and save it into single file "./rootfs.tgz" with tar.gz format .

	     ${0} -o ./rootfs.tgz ./rootfs

	 --> to install package files which indicated in unzip.rpm from ./rootfs into removeable media partition one (if exist) 

	     ${0} -o ./rootfs.tgz -i unzip.rpm ./rootfs 

	EOF
}

function check_dir() {
	_dirname="$1"
	_is_auto_create="$2"

	if [ -e "$_dirname" ];then
		if [ -d "$_dirname" ];then
			echo -n ""
		else 
			return 0
		fi
	else 
		[ "$_is_auto_create" ] && mkdir -p "$_dirname"
	fi
	return 1
}



showinfo=""
testmode=""
ofile=""

package_path="rpm/RPMS/arm"
package_full=""
package_op=""
package_list=""

install_to_dir="/tmp/${USER}/rootfs"
#install_to_dir=""
install_to_rmedia=""
forceoverwrite="0"
ignore_doc="0"
clean_tempdir="0"
while getopts "i:r:o:Ivtf" opt
do
	case ${opt} in
		v ) 
			showinfo="1" ;;
		t ) 
			testmode="1" ;;
		f ) 
			forceoverwrite="1" ;;
		I ) 
			ignore_doc="1" ;;
		r ) 
			package_full="${OPTARG}" 
			package_op="r"
			;;
		i ) 
			package_full="${OPTARG}" 
			package_op="i"
			;;
		o ) 
			ofile="${OPTARG}" 
			;;
		\? ) 
			usage 
			exit 0 ;;
	esac
done
shift "$(expr ${OPTIND} - 1)"


if [ "$1" ];then
	ROOT_INSTALL_FROM="$1"
else
	ROOT_INSTALL_FROM="./rootfs"
fi

if [ -d "$ROOT_INSTALL_FROM" ];then
	echo -n ""
else 
	echo "Rootfs which you want to install is not exist !! Please Check !"
	exit 1
fi

if [ "${package_full}" ];then
	if [ "$(echo ${package_full}|grep \/)" = "" ];then
		package_full="${package_path}/${package_full}"
	fi

	if [ -f "${package_full}" ];then
		package_list="$(rpm -qpl "${package_full}"|sed -e "s/\/opt\/freescale\/rootfs\/arm\///g")"
	else
		echo "package file \"${package_full}\" not exit !"
		exit 1
	fi
fi


MNTPT="$(mount_removeable_media)"
if [ "$(echo $MNTPT|grep '\/media')" ] ;then
	for P in $MNTPT 
	do
		# first partition is system partition .
		read -p "really install root file sytem into \"${P}\" (Y/N): " yn
		if [ "$yn" = "y" ] || [ "$yn" = "Y" ] ;then
			install_to_rmedia="${P}"
		fi
		break
	done
else
	echo "maybe mount removeable media fail !!"
fi



if [ "${install_to_rmedia}" = "" ] && [ "${ofile}" = "" ];then
	echo "Please insert removeable media into PC or use -o Option save rootfs into tgz ."
	exit 0
fi


if [ "${install_to_dir}" ];then

	if [ "${package_op}" != "r" ];then

		check_dir "${install_to_dir}" 1
		clean_tempdir="1"

		echo -n "clean up \"${install_to_dir}\" ... "
		docmd sudo rm -fr ${install_to_dir}/*
		docmd sudo sync
		echo "[Done]"

		if [ "${package_op}" = "i" ];then
			echo -n "install package files of \"${package_full}\" into \"${install_to_dir}/${item}\" ... "
			for item in ${package_list} 
			do
				[ "${showinfo}" ] && echo -n "install \"${ROOT_INSTALL_FROM}/${item}\" to \"\" ... "
				if [ -d "${ROOT_INSTALL_FROM}/${item}" ];then
					docmd sudo mkdir -p "${install_to_dir}/${item}"
				else
					docmd sudo cp -a "${ROOT_INSTALL_FROM}/${item}" "${install_to_dir}/${item}"
				fi
				if [ $? = 0 ];then
					[ "${showinfo}" ] && echo "[Done]"
				else
					[ "${showinfo}" ] && echo "[Fail]"
				fi
			done
			echo "[Done]"
		else
			echo -n "install rootfs from \"${ROOT_INSTALL_FROM}\" into \"${install_to_dir}\" ... "
			docmd sudo cp -a "${ROOT_INSTALL_FROM}/*" "${install_to_dir}/"
			docmd sudo sync
			echo "[Done]"
		fi


		echo -n "remove .svn folders ... "
		docmd sudo ${SHELLLIB_PATH}/rmsvn.sh "${install_to_dir}/"
		docmd sudo sync
		echo "[Done]"

		docmd sync
		docmd sync

		if [ "${ofile}" ];then
			docmd check_dir $(dirname ${ofile}) 1
			ofile="$(relpath_to_abspath ${ofile})"
			echo "tar \"${install_to_dir}\" into \"${ofile}\" ..."
			docmd cd "${install_to_dir}"
			echo "sudo tar zcf "${ofile}" ./"
			docmd sudo tar zcf "${ofile}" ./
			docmd cd -
		fi

	fi # [ "${package_op}" != "r" ]

	if [ "${install_to_rmedia}" ];then
		# removeable media exist ...

		if [ "${package_op}" = "r" ];then
			# remove package file from removeable media ...
			DIRLIST=".dirlist"
			echo "" > "${DIRLIST}"
			echo -n "remove package files of \"${package_full}\" from \"${install_to_rmedia}\" ... "
			for item in ${package_list} 
			do
				[ "${showinfo}" ] && echo -n "remove \"${install_to_rmedia}/${item}\" ... "
				if [ -d "${install_to_rmedia}/${item}" ];then
					echo "${item}" >> "${DIRLIST}"
				else
					docmd sudo rm -f "${install_to_rmedia}/${item}"
				fi

				if [ $? = 0 ];then
					[ "${showinfo}" ] && echo "[Done]"
				else
					[ "${showinfo}" ] && echo "[Fail]"
				fi
			done

			for item in $(cat "${DIRLIST}")
			do
				docmd sudo rmdir "${item}"
			done
			rm "${DIRLIST}"
			echo "[Done]"
		else
			# normal install into removeable media ...
			if [ "${forceoverwrite}" = "0" ] && [ "${package_op}" != "i" ] ;then
				echo -n "clean up \"${install_to_rmedia}/*\" ... "
				docmd sudo rm -fr "${install_to_rmedia}/*"
				docmd sudo sync
				echo "[Done]"
			fi

			echo -n "copy files from \"${install_to_dir}\" to \"${install_to_rmedia}\" ... "
			docmd sudo cp -a "${install_to_dir}/*" "${install_to_rmedia}/"
			docmd sudo sync
			echo "[Done]"

		fi
	fi



	if [ "${clean_tempdir}" = "1" ];then
		echo -n "clean temp files ... "
		docmd sudo rm -fr "/tmp/${USER}/rootfs"
		echo "[Done]"
	fi


	if [ "$(echo $MNTPT|grep '\/media')" ] ;then
		umount_removeable_media
	fi

	docmd sync
	docmd sync
	docmd sync
fi

cd "${workdir}"


