#!/bin/bash

#. ../build/envsetup.sh


#
# push file into target .
#
push_to_target() {
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
	KPLATFORM="$2"

	if [ -z "$(type gettop)" ];then
		echo "Please source build/envsetup.sh from the top of your android source tree !"
		exit 1
	fi

	#make imx6_android_defconfig
	#make mx50_rd3_android_config


	#lunch imx6q_arm2-eng
	#lunch imx50_rdp-eng

	if [ "${KPLATFORM}" ];then
		lunch "${KPLATFORM}"
	fi

	if [ -z "${ANDROID_EABI_TOOLCHAIN}" ];then
		echo "please run lunch \"${KPLATFORM}\" first !"
		exit 1
	fi

	if [ -z "${KTARGET}" ];then
		KTARGET="uImage"
	fi


	export ARCH=arm
	#export CROSS_COMPILE="$(gettop)/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-"
	export CROSS_COMPILE="arm-eabi-"
	#export CROSS_COMPILE="$(echo ${ANDROID_EABI_TOOLCHAIN}|sed -e "s/-.\..\..\/bin$/-/"|sed -e "s/^.*\///g")"
	make ${KTARGET} | tee make.log 

	return 0
}


