#!/bin/bash
KSRC_DIR="$(pwd)"
obj_dir=""

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
	make O="${obj_dir}" ARCH=arm CROSS_COMPILE=arm-none-eabi- 
else
	make ARCH=arm CROSS_COMPILE=arm-none-eabi- 
fi

