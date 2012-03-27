#!/bin/bash
function usage() {

	cat >&2 <<- EOF
	**************************************************************************
	release patch between two revision of svn repository .

	Usage: ${0} [-v] <svn repo URL> <svn repo revision from> <svn repo revision to> 


	Options:
	 -v: show infomation during prcessing .

	example:
	extract different files from revision 100 to revision 200 of svn server (URL=http://ebkrd2sw-desktop/svn/mx50/trunk/ltib/rpm/BUILD/linux-2.6.35.3)
	  ${0} http://ebkrd2sw-desktop/svn/mx50/trunk/ltib/rpm/BUILD/linux-2.6.35.3 100 200

	**************************************************************************
	EOF
	return 0
}


function _GetURL_SVN_MRev() {
	local URL
	local REV

	URL="${1}"
	REV="${2}"
	if [ -z "${REV}" ];then
		REV="HEAD"
	fi
	if [ "$(echo "${URL}"|grep "^.*://")" ];then
		querry_local="0"
	else
		querry_local="1"
	fi

	if [ "${querry_local}" = "1" ];then
		REVISION="$(LANG=C svn info "${URL}"|grep "Last\ Changed\ Rev"|sed -e "s/Last\ Changed\ Rev:\ //")"
	else
		REVISION="$(LANG=C svn info -r "${REV}" "${URL}"|grep "Last\ Changed\ Rev"|sed -e "s/Last\ Changed\ Rev:\ //")"
	fi
	echo "${REVISION}"
	return 0
}

function _GetURL_SVN_MDate() {
	local URL
	local REV

	URL="${1}"
	REV="${2}"
	if [ -z "${REV}" ];then
		REV="HEAD"
	fi
	if [ "$(echo "${URL}"|grep "^.*://")" ];then
		querry_local="0"
	else
		querry_local="1"
	fi

	if [ "${querry_local}" = "1" ];then
		_DATE="$(LANG=C svn info "${URL}"|grep "Last\ Changed\ Date"|sed -e "s/Last\ Changed\ Date:\ //"|sed -e "s/ (.*).*$//")"
	else
		_DATE="$(LANG=C svn info -r "${REV}" "${URL}"|grep "Last\ Changed\ Date"|sed -e "s/Last\ Changed\ Date:\ //"|sed -e "s/ (.*).*$//")"
	fi
	echo "${_DATE}"
	return 0
}

function _GetURL_SVN_RepoRoot() {
	local URL
	local REV

	URL="${1}"
	REV="${2}"
	if [ -z "${REV}" ];then
		REV="HEAD"
	fi
	if [ "$(echo "${URL}"|grep "^.*://")" ];then
		querry_local="0"
	else
		querry_local="1"
	fi

	if [ "${querry_local}" = "1" ];then
		_RepoRoot="$(LANG=C svn info "${URL}"|grep "Repository Root: "|sed -e "s/Repository\ Root:\ //")"
	else
		_RepoRoot="$(LANG=C svn info -r "${REV}" "${URL}"|grep "Repository Root: "|sed -e "s/Repository\ Root:\ //")"
	fi
	echo "${_RepoRoot}"
	return 0
}

function _GetURL_SVN_Path() {
	local URL
	local REV

	URL="${1}"
	REV="${2}"
	if [ -z "${REV}" ];then
		REV="HEAD"
	fi
	if [ "$(echo "${URL}"|grep "^.*://")" ];then
		querry_local="0"
	else
		querry_local="1"
	fi

	if [ "${querry_local}" = "1" ];then
		_Path="$(LANG=C svn info "${URL}"|grep "Path: "|sed -e "s/Path:\ //")"
	else
		_Path="$(LANG=C svn info -r "${REV}" "${URL}"|grep "Path: "|sed -e "s/Path:\ //")"
	fi
	echo "${_Path}"
	return 0
}

function export_svn_porject() {
	local _repo_root
	local _listfile
	local _rev_num


	local _work_dir
	local _dir
	local _mfile
	local _chk
	local _result


	_repo_root=$1
	_listfile=$2
	_rev_num=$3
	_repo_path=$4


	_work_dir="$(pwd)"

	
	echo "export ${_repo_root}/${_repo_path} ... "
	while read _mfile
	do
		echo "export ${_mfile} ... "
		_dir="$(dirname ${_mfile})"

		cd "${_work_dir}"
		mkdir -p "${_dir}"
		cd "${_dir}"

		_result="$(svn export -r ${_rev_num} "${_repo_root}/${_mfile}")" 
		_chk=$?
		if [ $_chk != 0 ];then
			echo "export ${_repo_root}/${_mfile} fail !! [ $_chk ] "
			echo "result=\"$_result\""
		fi
	done < "${_listfile}"

	cd "${_work_dir}"

	return 0
}




SVN_URL=$1
REV_FROM=$2
REV_TO=$3
FILTER=$4

unknown_opt=0
showinfo=0
while getopts ":tv" opt
do
	case ${opt} in
		t ) 
			testmode="1" ;;
		v ) 
			showinfo="1" ;;
		\? ) 
			unknown_opt=1
			;;
	esac
done
shift "$(expr ${OPTIND} - 1)"

if [ "$unknown_opt" = 1 ] || [ -z "${SVN_URL}" ] || [ -z "${REV_FROM}" ] || [ -z "${REV_TO}" ];then
	usage
	exit 0
fi




TMP_FILE="/tmp/svnpatch_$(date +%y%m%d%H%M)"
WORK_DIR="$(pwd)"

echo "query svn histories ... "
svn log -v -r ${REV_FROM}:${REV_TO} "${SVN_URL}" |grep "^[[:blank:]]*[MA][[:blank:]]" | sed "s/^[[:blank:]]*[MAD][[:blank:]]\///" > "${TMP_FILE}_mlistall"

if [ -z "$(cat "${TMP_FILE}_mlistall")" ];then
	rm -f "${TMP_FILE}_mlistall"
	exit 1
fi

echo -n "" > "${TMP_FILE}_mlist"
while read _mfile
do
	if [ -z "$(cat "${TMP_FILE}_mlist"|grep "${_mfile}")" ];then
		echo "${_mfile}" >> "${TMP_FILE}_mlist"
	fi
done < "${TMP_FILE}_mlistall"



if [ "${FILTER}" ];then
	cat "${TMP_FILE}_mlist" | grep "${FILTER}" > "${TMP_FILE}_mlist_filter"
	cp "${TMP_FILE}_mlist_filter" "${TMP_FILE}_mlist"
fi


echo "query svn server ... "
REL_NAME="$(_GetURL_SVN_Path "${SVN_URL}")_r${REV_FROM}_to_r${REV_TO}"
REPO_ROOT="$(_GetURL_SVN_RepoRoot "${SVN_URL}" "${REV_TO}")"
REPO_PATH="$(_GetURL_SVN_Path "${SVN_URL}")"

echo "reop_root=\"$REPO_ROOT\""
#exit 0

if [ "${REL_NAME}" ];then
	if [ -d "${REL_NAME}" ];then
		echo "\"${REL_NAME}\" folder exist !! please check and remove it " 
	else

		mkdir "${REL_NAME}"
		mkdir "${REL_NAME}/${REV_FROM}"
		mkdir "${REL_NAME}/${REV_TO}"
		
 
		cd "${WORK_DIR}/${REL_NAME}/${REV_FROM}"
		export_svn_porject "${REPO_ROOT}" "${TMP_FILE}_mlist" "${REV_FROM}" "${REPO_PATH}"


		cd "${WORK_DIR}/${REL_NAME}/${REV_TO}"
		export_svn_porject "${REPO_ROOT}" "${TMP_FILE}_mlist" "${REV_TO}" "${REPO_PATH}"

	fi
fi

cd "${WORK_DIR}"
rm -f ${TMP_FILE}*

exit 0


