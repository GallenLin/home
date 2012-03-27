#!/bin/bash
function usage() {
	cat >&2 <<- EOF

	This tool help you update files into tar/tar.gz/tgz folder .
	where the files specificated in folder that you given in parameter .

	Usage: ${0} [-t] [-v] [tar file] [folder]
	
	 folder : files you want to update into tar file please put them into this folder .
	 tar file : filename with .tar, .tar.gz or tgz format that you want to update .

	Options:
	 -t: run as test mode : it's just show what will do .
	 -v: show infomation during prcessing .

	example:

	 ${0} ../rootfs.tar ./

	EOF
}

function relpath_to_abspath() {
	if [ "$(echo $1|grep ^\/)" ];then
		echo "$1"
	elif [ "$(echo $1|grep ^\.)" ];then
		echo "$(pwd)/$(echo $1|sed -s "s/^\.\///g")"
	else
		echo "$(pwd)/$1"
	fi
}


testmode="0"
showinfo="0"

while getopts ":tv" opt
do
	case ${opt} in
		t ) 
			testmode="1" ;;
		v ) 
			showinfo="1" ;;
		\? ) 
			usage 
			exit 0 ;;
	esac
done
shift "$(expr ${OPTIND} - 1)"



function docmd() {
	if [ "$testmode" = "1" ];then
		echo $@
	else
		$@
	fi
}


workfolder="$(pwd)"
toolabs="$(relpath_to_abspath ${0})"
toolfolder="$(dirname ${toolabs})"



TAR_FILE_ABS=$(relpath_to_abspath ${1})
UPDATE_DIR_ABS=$(relpath_to_abspath ${2})

if [ -f ${TAR_FILE_ABS} ];then
	echo -n ""
else
	echo "\"${TAR_FILE_ABS}\" not file !"
	usage
 	exit -1	
fi	

if [ -d ${UPDATE_DIR_ABS} ];then
	echo -n ""
else
	echo "\"${UPDATE_DIR_ABS}\" not dir !"
	usage
 	exit -1	
fi	

##
##
is_compressed="0"
if [ "$(file ${TAR_FILE_ABS} | grep "gzip compressed data")" ];then
	docmd gzip -c -d "${TAR_FILE_ABS}" > "${TOOL_DIR}/.tmp.tar"
	if [ $? = 0 ];then
		docmd cp -f "${TOOL_DIR}/.tmp.tar" ${TAR_FILE_ABS}
		docmd rm -f "${TOOL_DIR}/.tmp.tar"
	fi
	sync
	is_compressed="1"
fi

cd "${UPDATE_DIR_ABS}"

list_to_update=$(find . -type f)
for file_to_update in ${list_to_update} 
do
	docmd tar --delete -v -f "${TAR_FILE_ABS}" "${file_to_update}" > /dev/null 2>&1 
	docmd tar -rv -f "${TAR_FILE_ABS}" "${file_to_update}"
done

cd "${workfolder}"

if [ "${is_compressed}" = "1" ];then
	docmd gzip -c "${TAR_FILE_ABS}" > "${TOOL_DIR}/.tmp.tgz"
	if [ $? = 0 ];then
		docmd cp -f "${TOOL_DIR}/.tmp.tgz" ${TAR_FILE_ABS}
		docmd rm -f "${TOOL_DIR}/.tmp.tgz"
	fi
	sync

fi

