#!/bin/bash

usage() {
	cat >&2 <<- EOF
	**************************************************************************
	$0 can help you to remove git submodule .

	remove submodule in ".git/config" 

	Usage: ${0} [OPTIONS] [submodule a] [submodule b] [submodule c] ...
	

	OPTIONS :
	 -h: show this help .

	example:

	 remove git submodule which folder name is subA :
	  ${0} subA

	 remove git submodules include folder name subA , subB and subC :
	  ${0} subA subB subC
	
	 remove all git submodule in this folder :
	  ${0} 

	**************************************************************************
	EOF
	return 0
}


function rm_git_submodule() {
	_ret=0
	RM_SUBMOD_DIR="$1"
	#echo "\$*=\"$*\",\$1=\"$1\",\$2=\"$2\","

	_proc_file=".git/config"
	if [ -f "${_proc_file}" ] && [ "$(cat "${_proc_file}" |grep -n "\[submodule \"${RM_SUBMOD_DIR}\"\]")" ];then
		_cfg_submod_line_start="$(cat "${_proc_file}" |grep -n "\[submodule \"${RM_SUBMOD_DIR}\"\]"|awk -F: '{print $1}')"
		echo "submodule ${RM_SUBMOD_DIR} @ line ${_cfg_submod_line_start} of ${_proc_file}"
		_cfg_submod_line_end="$(expr ${_cfg_submod_line_start} + 1)"
		sed -i "${_cfg_submod_line_start},${_cfg_submod_line_end}d" "${_proc_file}"
	fi

	
	_proc_file=".gitmodules"
	if [ -f "${_proc_file}" ] && [ "$(cat "${_proc_file}" |grep -n "\[submodule \"${RM_SUBMOD_DIR}\"\]")" ] ;then
		_git_submod_line_start="$(cat "${_proc_file}" |grep -n "\[submodule \"${RM_SUBMOD_DIR}\"\]"|awk -F: '{print $1}')"
		echo "submodule ${RM_SUBMOD_DIR} @ line ${_git_submod_line_start} of ${_proc_file}"
		_git_submod_line_end="$(expr ${_git_submod_line_start} + 2)"
		sed -i "${_git_submod_line_start},${_git_submod_line_end}d" "${_proc_file}"
	fi

	if [ -d "${RM_SUBMOD_DIR}" ];then
		echo "remove submodule folder ${RM_SUBMOD_DIR}"
		git rm --cached "${RM_SUBMOD_DIR}"
		rm -fr "${RM_SUBMOD_DIR}"
	fi

	return ${_ret}
}



while getopts "t:h" opt
do
	case ${opt} in
		h ) 
			unknown_opt=1
			;;
		\? ) 
			unknown_opt=1
			;;
		t ) 
			test_arg="${OPTARG}"
			unknown_opt=0
			;;
	esac
done
shift "$(expr ${OPTIND} - 1)"

if [ "$unknown_opt" = 1 ];then
	usage
	exit 0
fi




WORK_DIR="$(pwd)"

for i in $* 
do
	rm_git_submodule ${i}
done

exit 0

