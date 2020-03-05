#!/bin/bash

#. ../build/envsetup.sh

usage() {
	echo "$0 <VENDOR> <SOC>"
	echo "  <VENDOR> : Rockchip|NXP|Freescale|Allwinner"
	echo "  <SOC> : rk3288|rk3368h|px30||mx50|mx6sl|mx6dl|mx6sll|mx6ull|mx7d|b300"
	return 0
}

change_droid_out_dir() {
	_NewOutPath="$1"

	WORK_DIR="$(pwd)"
	droid_top_basename="$(basename ${WORK_DIR})"
	if [ -z "${_NewOutPath}" ];then
		_NewOutPath="$(echo "${WORK_DIR}"|sed -e "s/\/${droid_top_basename}$/\/${droid_top_basename}_out/")"
	fi

	if [ -d "out" ];then
		echo "\"out\" existing ! you can remove it that we will use \"${_NewOutPath}\" instead of \"out\" ."
		return 0
	fi

	export OUT_DIR="${_NewOutPath}"
	return 0
}

myandroid_setup_env() {
	local vendor="$1"
	local soc="$2"

	#if [ -z "$(type gettop)" ];then
		if [ -f build/envsetup.sh ];then
			. build/envsetup.sh
		else
			echo "Please source build/envsetup.sh from the top of your android source tree !"
			return 1 
		fi
	#fi
	
	if [ -z "${ANDROID_PRODUCT_OUT}" ];then
		lunch
	fi

	if [ -z "${ANDROID_PRODUCT_OUT}" ];then
		echo "please run lunch first !"
		return 1
	fi

	echo "vendor=${vendor},soc=${soc}"

	if [ "${vendor}" = "Rockchip" ];then
		if [ "${soc}" = "rk3368h" ] || [ "${soc}" = "px30" ];then
			# for boot make options :
			export ARCHV=aarch64
			# for kernel options :
			export ARCH=arm64
			echo "ARCH=$ARCH"
		elif [ "${soc}" = "rk3288" ];then
			export ARCH=arm
			export SUBARCH=arm
		fi
	else
		export ARCH=arm
		export SUBARCH=arm
	fi


	DROID_VERSION="$(printconfig|grep PLATFORM_VERSION=|sed -e "s/PLATFORM_VERSION=//")"
	TARGET_ARCH="$(printconfig|grep TARGET_ARCH=|sed -e "s/TARGET_ARCH=//")"
	
	if [ "${soc}" = "rk3288" ] && [ "${DROID_VERSION}" = "6.0.1" ] ;then
		#echo "rockchip sdk will select correct toolchain automatically ."
		export CROSS_COMPILE=${ANDROID_TOOLCHAIN_2ND_ARCH}/arm/arm-eabi-4.8/bin/arm-eabi-
	elif [ "${DROID_VERSION}" = "5.1.1" ];then
		export CROSS_COMPILE=${ANDROID_BUILD_TOP}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin/arm-eabi-
	elif [ "$(echo "${DROID_VERSION}" |grep "^8\.")" ];then
		if [ "${TARGET_ARCH}" = "arm64" ];then
			export CROSS_COMPILE=${ANDROID_TOOLCHAIN}/aarch64-linux-androidkernel-
		else
			if [ "${ANDROID_TOOLCHAIN_2ND_ARCH}" ];then
				export CROSS_COMPILE=${ANDROID_TOOLCHAIN_2ND_ARCH}/arm-linux-androidkernel-
			else 
				export CROSS_COMPILE=${ANDROID_TOOLCHAIN}/arm-linux-androidkernel-
			fi
		fi

		if [ "${soc}" = "mx6dl" ];then
			export LOADADDR=0x10008000
		elif [ "${soc}" = "mx6sl" ] || [ "${soc}" = "mx7d" ];then
			export LOADADDR=0x80008000
		fi

		if [ "${vendor}" = "NXP" ] || [ "${vendor}" = "Freescale" ];then
			export KCFLAGS=-mno-android
		fi

	else
		export CROSS_COMPILE=${ANDROID_EABI_TOOLCHAIN}/arm-eabi-
		if [ ! -f "${CROSS_COMPILE}gcc" ];then
			export CROSS_COMPILE=${ARM_EABI_TOOLCHAIN}/arm-eabi-
		fi
	fi

	return 0
}

myandroid_setup_ccache() {
	_ccache_dir=$1
	_ccache_max_size=$2 #eg, 10G ,500M .

	if [ -z "$(type gettop)" ];then
		echo "Please source build/envsetup.sh from the top of your android source tree !"
		return 1
	fi

	echo "create ${_ccache_max_size} @ \"${_ccache_dir}\" for CCACHE "

	export USE_CCACHE=1

	if [ ! -d "${_ccache_dir}" ];then
		mkdir -p "${_ccache_dir}"
	fi
	export CCACHE_DIR="${_ccache_dir}"

	
	if [ -f "${ANDROID_BUILD_TOP}/prebuilts/misc/linux-x86/ccache/ccache" ];then
		eval "${ANDROID_BUILD_TOP}/prebuilts/misc/linux-x86/ccache/ccache -M "${_ccache_max_size}""
	else
		eval "${ANDROID_BUILD_TOP}/prebuilt/linux-x86/ccache/ccache -M "${_ccache_max_size}""
	fi

	return 0
}



#
# push file into target .
#
myandroid_push_to_target() {
	output_path="$1"

	_current_dir="$(pwd)"

	if [ -z "${ANDROID_PRODUCT_OUT}" ];then
		echo "please run lunch first !"
		return 1
	fi

	
	echo "push ${ANDROID_PRODUCT_OUT}/${output_path} -> /${output_path}"
	cd "${ANDROID_PRODUCT_OUT}"
	adb push "${output_path}" "/${output_path}"

	cd "${_current_dir}"

	return 0
}


#
# make kernel ...
#
kmake() {
	KTARGET="$1"
	make ${KTARGET}
	return 0
}

VENDOR="$1"
SOC="$2"


if [ -z "${VENDOR}" ];then
	echo "<VENDOR> cannot empty"
	usage
	return 1
fi

if [ -z "${SOC}" ];then
	echo "<SOC> cannot empty"
	usage 
	return 1
fi

echo "you can make your out/ into different path by following command : "
echo "  make OUT_DIR=xxxx"

# setup droid "out" folder different from android's defualt value .
change_droid_out_dir

echo "current OUT_DIR=\"${OUT_DIR}\""

#  
myandroid_setup_env "${VENDOR}" "${SOC}"

# setup ccache to 20GB .
#myandroid_setup_ccache ${HOME}/ccache 20G

#
# to fix making android 8.1 problem in ubuntu 18.04
#  
#   flex-2.5.39: loadlocale.c:130: _nl_intern_locale_data: Assertion `cnt < (sizeof (_nl_value_type_LC_TIME) / sizeof (_nl_value_type_LC_TIME[0]))' failed.
# 
export LC_ALL=C
#
#


return 0 

