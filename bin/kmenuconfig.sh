#!/bin/bash

. kfunc.sh

setup_platform $1

obj_dir="$(get_obj_dir)"


if [ "${obj_dir}" ];then
	O_OPT="O=${obj_dir}"
fi


make ${O_OPT} ARCH="${platform_arch}" CROSS_COMPILE= menuconfig

