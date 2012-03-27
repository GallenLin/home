#!/bin/bash
# purpose : 
#		help you to install kernel binaries into target directory . 
# 
# common :
# 	run this script in kernel source directory .
#
# author :
#		Gallen Lin
#
#

. kfunc.sh

# ltib ..
install_dir="../../../rootfs/boot/"
install_mdir="../../../rootfs"

function usage() {
	cat >&2 <<- EOF

	This tool help to install kernel binaries(zImage and modules) into rootfs .
	 default rootfs path : ${install_mdir}
	 default rootfs boot path : ${install_dir}

	 Usage: ${0} [platform name]
	   platform name : mx35 | x86
	
	Options:
	  [-r <rootpath>]: setup root path where will install the binaries file .

	Example:

	 --> to install kernel binaries files for platform mx35 into ${install_mdir}  

	     ${0} mx35

	 --> to install kernel binaries files for platform mx35 into /home/myhome/rootfs  

	     ${0} -r /home/myhome/rootfs mx35 

	EOF
}

while getopts "r:" opt
do
	case ${opt} in
		r ) 
			install_dir="${OPTARG}/boot/"
			install_mdir="${OPTARG}"
			;;
		\? ) 
			usage 
			exit 0 ;;
	esac
done
shift "$(expr ${OPTIND} - 1)"



setup_platform $1

obj_dir="$(get_obj_dir)"

if [ "${obj_dir}" ];then
	O_OPT="O=${obj_dir}"
fi

echo "========= make install to \"${install_dir}\" ==================="
make ${O_OPT} INSTALL_PATH="${install_dir}" ARCH="${platform_arch}" CROSS_COMPILE="${platform_cross}" install 
echo "========= make modules_install to \"${install_mdir}\" ==================="
make ${O_OPT} INSTALL_MOD_PATH="${install_mdir}" ARCH="${platform_arch}" CROSS_COMPILE="${platform_cross}" modules_install 
echo ""


