#!/bin/bash
function usage() {
	cat >&2 <<- EOF

	This tool help you to pack project in svn project .

	Usage: ${0} [Options] <URL> [PackName] [PackFormat]
	
	 URL : URL of SVN project . eg, "file:///home/svn/project1" 
	 PackName : Package Name . eg, "Project"
	 PackFormat : Package format . eg, "tgz" | "bz2" | "zip"

	Options:
	 -t: run as test mode : it's just show what will do .
	 -v: show infomation during prcessing .
	 -r <rev> : get with revision option .
	 -o : svn info outside pack file .
	 -h: show this help .

	example:

	 ${0} https://gallen-desktop:8443/svn/ntx/ltib ltib zip

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
svninfo_outside="0"
REV_TO_EXPORT=""
while getopts ":r:tvoh" opt
do
	case ${opt} in
		r ) 
			REV_TO_EXPORT="${OPTARG}"
			;;
		t ) 
			testmode="1" ;;
		v ) 
			showinfo="1" ;;
		o )
			svninfo_outside="1" ;;
		h )
			usage
			exit 0
			;;
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






function _GetURL_MRevision() {
	URL="${1}"
	REV="${2}"
	if [ -z "${REV}" ];then
		REV="HEAD"
	fi
	REVISION="$(LANG=C svn info -r "${REV}" "${URL}"|grep "Last\ Changed\ Rev"|sed -e "s/Last\ Changed\ Rev:\ //")"
	echo ${REVISION}
}
function _GetURL_Revision() {
	URL="${1}"
	REV="${2}"
	if [ -z "${REV}" ];then
		REV="HEAD"
	fi
	_TMP="$(LANG=C svn info -r "${REV}" "${URL}"|grep "Revision:")"
	REVISION="$(echo "${_TMP}"|sed -e "s/Revision: //" 2>/dev/null)"
	echo ${REVISION}
}

function _ExportAndPackSvnProject() {
	# [1] svn project full url : 
	#		example : https://gallen-desktop:8443/svn/trunk/aaa

	if [ "${1}" = "" ];then
		echo "URL cannot empty !!"
		usage
		exit 2
	fi
	FULLURL="${1}"
	# [2] pack name : 
	#		example : aaa

	PACKNAME=""
	if [ "${2}" ];then
		PACKNAME="${2}"
	else 
		PACKNAME="$(basename "${FULLURL}")"
	fi

	# [3] package format :
	#		example : [tgz|zip|bz2]
	FORMAT="tgz"
	if [ "${3}" ];then
		FORMAT="${3}"
	fi

	# [4] export revision number :
	#		example : 222
	EXPORT_REV=""
	if [ "${4}" ];then
		EXPORT_REV="${4}"
	fi

	# [5] svn info outside :
	#		example : [1|0]
	SVNINFO_OUTSIDE="0"
	if [ "${5}" ];then
		SVNINFO_OUTSIDE="${5}"
	fi

	DATE="$(date +%Y%m%d)"
	REV=$(_GetURL_Revision ${FULLURL} ${EXPORT_REV})
	MREV=$(_GetURL_MRevision ${FULLURL} ${EXPORT_REV})


	
	if [ "${EXPORT_REV}" ];then
		docmd svn export -r ${EXPORT_REV} ${FULLURL} ${PACKNAME}
		LANG=C docmd svn info -r ${EXPORT_REV} ${FULLURL} > ${PACKNAME}_${DATE}_R${REV}r${MREV}-svninfo.txt
	else	
		docmd svn export ${FULLURL} ${PACKNAME}
		LANG=C docmd svn info ${FULLURL} > ${PACKNAME}_${DATE}_R${REV}r${MREV}-svninfo.txt
	fi


	case "${FORMAT}" in
		"tgz")
			echo "-- FORMAT : tgz --"
			if [ "0" == ${SVNINFO_OUTSIDE} ];then
				docmd tar zcvf ${PACKNAME}_${DATE}_R${REV}r${MREV}.${FORMAT} ${PACKNAME} ${PACKNAME}_${DATE}_R${REV}r${MREV}-svninfo.txt
			else
				docmd tar zcvf ${PACKNAME}_${DATE}_R${REV}r${MREV}.${FORMAT} ${PACKNAME}
			fi
			;;
		"bz2")
			echo "-- FORMAT : bz2 --"
			if [ "0" == ${SVNINFO_OUTSIDE} ];then
				docmd tar jcvf ${PACKNAME}_${DATE}_R${REV}r${MREV}.${FORMAT} ${PACKNAME} ${PACKNAME}_${DATE}_R${REV}r${MREV}-svninfo.txt
			else
				docmd tar jcvf ${PACKNAME}_${DATE}_R${REV}r${MREV}.${FORMAT} ${PACKNAME} 
			fi
			;;
		"zip")
			echo "-- FORMAT : zip --"
			if [ "0" == ${SVNINFO_OUTSIDE} ];then
				docmd zip -r ${PACKNAME}_${DATE}_R${REV}r${MREV}.${FORMAT} ${PACKNAME} ${PACKNAME}_${DATE}_R${REV}r${MREV}-svninfo.txt
			else
				docmd zip -r ${PACKNAME}_${DATE}_R${REV}r${MREV}.${FORMAT} ${PACKNAME} 
			fi
			;;
	esac

	md5sum ${PACKNAME}_${DATE}_R${REV}r${MREV}.${FORMAT} > ${PACKNAME}_${DATE}_R${REV}r${MREV}.${FORMAT}.md5

	docmd rm -fr ${PACKNAME}
	if [ "0" == ${SVNINFO_OUTSIDE} ];then
		docmd rm -f ${PACKNAME}-svninfo.txt
	fi
}


FULLURL="${1}"
PACKNAME="${2}"
FORMAT="${3}"
_ExportAndPackSvnProject "${FULLURL}" "${PACKNAME}" "${FORMAT}" "${REV_TO_EXPORT}" "${svninfo_outside}"


