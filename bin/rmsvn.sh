#!/bin/bash
function usage() {
	cat >&2 <<- EOF

	This tool help you remove all ".svn" folder .

	Usage: ${0} [-t] [-v] [folder]
	
	folder: under this folder that you want to remove all ".svn" folder .

	Options:
		-t: run as test mode : it's just show what will do .
		-v: show infomation during prcessing .

	example:

	EOF
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

if [ "$1" ];then
	cd "$1"
fi

svnfolderlist=$(find . -name .svn)
for svnfld in $svnfolderlist
do
	if [ -d "${svnfld}" ];then
		[ "$showinfo" = "1" ] && echo -n "remove $svnfld ..."
		docmd rm -fr "${svnfld}"
		[ "$showinfo" = "1" ] && echo "[done]"
	fi
done

cd "${workfolder}"

