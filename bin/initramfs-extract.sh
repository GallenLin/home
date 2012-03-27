#!/bin/bash

initramfs_img="${1}"
initramfs_dist_path="${2}"

rm_tmp() {
	find /tmp -name "${tmp_prefix}*" 2>/dev/null |
	while read tmpf
	do
		#echo "remove temp file \"${tmpf}\""
		rm -f "${tmpf}"
	done
	return 0
}

clean_up() {
	rm_tmp
	return $?
}

usage() {
	echo ""
	echo "$0 usage :"
	echo "$0 <initramfs image> [dist_path]"
	echo ""
	return 0
}




work_dir="$(pwd)"
id_str="$(date +%Y%m%d%H%M%S)"
tmp_prefix="initramfs-extract_tmp_${id_str}"
tmp_initramfs="/tmp/${tmp_prefix}_initramfs"
tmp_initramfs_gz="/tmp/${tmp_prefix}_initramfs.gz"


if [ ! "$#" -ge "1" ];then
	echo "parameter error !"
	usage
	clean_up
	exit 1
fi

file_type="$(file "${initramfs_img}")"

if [ "$(echo "${file_type}" |grep "gzip compressed data")" ];then
	gzip -c -d "${initramfs_img}" > "${tmp_initramfs}"
elif [ "$(echo "${file_type}" |grep "u-boot")" ];then
	dd if="${initramfs_img}" of="${tmp_initramfs_gz}" skip=64 bs=1
	gzip -c -d "${tmp_initramfs_gz}" > "${tmp_initramfs}"
else
	echo "unkown file type -- ${file_type}"
	clean_up
	exit 1
fi

file_type="$(file "${tmp_initramfs}")"
if [ "$(echo "${file_type}"|grep "cpio archive")" ];then

	if [ "${initramfs_dist_path}" ] && [ ! -d "${initramfs_dist_path}" ] ;then
		mkdir -p "${initramfs_dist_path}"
		cd "${initramfs_dist_path}"
	fi
	cpio -i < "${tmp_initramfs}"
	cd "${work_dir}"

else
	echo "\"${initramfs_img}\" not cpio ramfs image"
	clean_up
	exit 1
fi

clean_up
exit 0


