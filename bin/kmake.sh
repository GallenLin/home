#!/bin/bash
function usage() {
	cat >&2 <<- EOF
	******************************************************
	make tool for kernel source .

	Usage: ${0} [OPTIONS] [PLATFORM] [TARGET]
	
	OPTIONS: 
	 -h: this help message .
	
	PLATFORM:
	 target platform : [mx35|mx35-linux|x86|m166e|mx50|mx50-linux]

	TARGET:
	 make target of kernel source .

	---------------------
	example:
	 
	  ${0} mx35 
	  ${0} mx35 clean
	  ${0} mx35 menuconfig

	******************************************************

	EOF
}

. kfunc.sh


PLATFORM_NAME="${1}"
MAKE_TARGET="${2}"

platform_arch=""
platform_cross=""


_tmp_file="/tmp/${USER}_tmp"

echo -n "" > "${_tmp_file}"
while getopts ":h" opt
do
	case ${opt} in
		h ) 
			usage 
			exit 0 ;;
		* )
			echo -n "${opt} ${OPTARG} " >> "${_tmp_file}"
			;;
	esac
done
shift "$(expr ${OPTIND} - 1)"


setup_platform "${PLATFORM_NAME}"

#obj_dir="$(get_obj_dir)"
#if [ "${obj_dir}" ];then
#	O_OPT="O=${obj_dir}"
#fi
#make ${O_OPT} ARCH="${platform_arch}" CROSS_COMPILE="${platform_cross}" 
OTHER_MAKE_OPTIONS="$(cat "${_tmp_file}")"
make ${OTHER_MAKE_OPTIONS} ARCH="${platform_arch}" CROSS_COMPILE="${platform_cross}" ${MAKE_TARGET} |tee make.log


