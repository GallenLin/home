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

KSRC_DIR="$(pwd)"
obj_dir=""

# ltib ..
install_dir="../../../rootfs/boot/"
install_mdir="../../../rootfs"

OBJDIR_CFG="objdir.cfg"
if [ -f "${OBJDIR_CFG}" ];then
	obj_dir="$(cat ${OBJDIR_CFG})"
else
	obj_dir="$1"
	#obj_dir="${HOME}/out/$(basename $KSRC_DIR)"
fi


if [ "${obj_dir}" ];then
	if [ -d "${obj_dir}" ];then
		echo -n ""
	else
		mkdir -p "${obj_dir}"
		[ $? != 0 ] && echo "create dir \"${obj_dir}\" fail !" && exit -1
	fi

	echo "========= make install to \"${install_dir}\" ==================="
	make -n O="${obj_dir}" INSTALL_PATH="${install_dir}" ARCH=arm CROSS_COMPILE=arm-none-eabi- install 
	echo "========= make modules_install to \"${install_mdir}\" ==================="
	make -n O="${obj_dir}" INSTALL_MOD_PATH="${install_mdir}" ARCH=arm CROSS_COMPILE=arm-none-eabi- modules_install 
	echo ""
else 
	echo "========= make install to \"${install_dir}\" ==================="
	make -n INSTALL_PATH="${install_dir}" ARCH=arm CROSS_COMPILE=arm-none-eabi- install 
	echo "========= make modules_install to \"${install_mdir}\" ==================="
	make -n INSTALL_MOD_PATH="${install_mdir}" ARCH=arm CROSS_COMPILE=arm-none-eabi- modules_install 
	echo ""
fi


