#!/bin/bash

#. ../build/envsetup.sh

setup_ccache() {
	_ccache_dir=$1
	_ccache_max_size=$2 #eg, 10G ,500M .

	if [ -z "$(type gettop)" ];then
		echo "Please source build/envsetup.sh from the top of your android source tree !"
		exit 1
	fi


	export USE_CCACHE=1
	export CCACHE_DIR="$_ccache_dir"

	${gettop}/prebuilt/linux-x86/ccache/ccache -M "$_ccache_max_size"

	return 0
}

config_android_udev_access() {
	_username="${USERNAME}"
	_udev_rule_file="/etc/udev/rules.d/51-android.rules"
	_tmp_file="/tmp/android-usb-udev.rules"
	config_append=0


	#####################################################
	_signature="## android usb devices official ..." # 
	if [ ! -f "${_udev_rule_file}" ] || [ -z "$(cat "${_udev_rule_file}"|grep "${_signature}")" ];then
		echo "append ${_signature} into ${_udev_rule_file} ..."
		config_append=1
		echo "${_signature}[" >> "${_tmp_file}"

		# content of udev config file ...
cat >&2 <<- EOF >> "${_tmp_file}"
# adb protocol on passion (Nexus One)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e12", MODE="0600", OWNER="${_username}"
# fastboot protocol on passion (Nexus One)
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", ATTR{idProduct}=="0fff", MODE="0600", OWNER="${_username}"
# adb protocol on crespo/crespo4g (Nexus S)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e22", MODE="0600", OWNER="${_username}"
# fastboot protocol on crespo/crespo4g (Nexus S)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e20", MODE="0600", OWNER="${_username}"
# adb protocol on stingray/wingray (Xoom)
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", ATTR{idProduct}=="70a9", MODE="0600", OWNER="${_username}"
# fastboot protocol on stingray/wingray (Xoom)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="708c", MODE="0600", OWNER="${_username}"
# adb protocol on maguro/toro (Galaxy Nexus)
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ATTR{idProduct}=="6860", MODE="0600", OWNER="${_username}"
# fastboot protocol on maguro/toro (Galaxy Nexus)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e30", MODE="0600", OWNER="${_username}"
# adb protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d101", MODE="0600", OWNER="${_username}"
# fastboot protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d022", MODE="0600", OWNER="${_username}"
# usbboot protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d010", MODE="0600", OWNER="${_username}"
EOF

		echo "${_signature}]" >> "${_tmp_file}"
		echo "" >> "${_tmp_file}"
	else
		echo "${_signature} is existed !"
	fi
	##############################################################


	#####################################################
	_signature="## android usb devices for fsl ..." # 
	if [ ! -f "${_udev_rule_file}" ] || [ -z "$(cat "${_udev_rule_file}"|grep "${_signature}")" ];then
		echo "append ${_signature} into ${_udev_rule_file} ..."
		config_append=1
		echo "${_signature}[" >> "${_tmp_file}"

		# content of udev config file ...
cat >&2 <<- EOF >> "${_tmp_file}"
# usbboot protocol on freescale mx50_rdp 
SUBSYSTEM=="usb", ATTR{idVendor}=="15a2", ATTR{idProduct}=="0c02", MODE="0600", OWNER="${_username}"
EOF

		echo "${_signature}]" >> "${_tmp_file}"
		echo "" >> "${_tmp_file}"
	else
		echo "${_signature} is existed !"
	fi
	##############################################################
	
	if [ 1=${config_append} ];then
		sudo -s "cat "${_tmp_file}" >> "${_udev_rule_file}""
		rm -f ${_tmp_file}
	fi

	return 0
}


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


