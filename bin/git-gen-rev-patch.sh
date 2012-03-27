#!/bin/bash

usage() {
	echo ""
	echo "usage :"
	echo "$0 <git_repo_path> <patch_path> [git_rev]"
	echo " <git_repo_path> : path of git's repo ."
	echo " <patch_path> : name of path that will be created automatically ."
	echo " output : "
	echo "  a folder @ <patch_path>"
	echo "  a file @ <patch_path>.del"
	echo " common :"
	echo "  the output can be used by 'update_rootfs.sh'"
	echo ""
	return 0
}


repo_path="${1}"
patch_name="${2}"
rev="${3}"

work_dir="$(pwd)"

if [ -z "${repo_path}" ] || [ -z "${patch_name}" ];then
	usage
	exit 1
fi

if [ -d "${patch_name}" ] || [ -f "${patch_name}" ];then
	echo "\"${patch_name}\" | "${patch_name}.del" is existed !"
	usage
	exit 1
fi

if [ ! -d "${repo_path}" ];then
	echo "repo \"${repo_path}\" is not existed !"
	usage
	exit 1
fi


cd "${repo_path}"
_tmp_repo_path="$(git rev-parse --git-dir)"
repo_full_path="$(pwd)/${_tmp_repo_path}"

cd "${work_dir}"



# initialize ...
mkdir -p "${patch_name}"
ln -s "${repo_full_path}" "${patch_name}/.git"
echo -n "" > "${patch_name}.del"

# 
#echo "repo_full_path=${repo_full_path}"
git --no-pager --git-dir="${repo_full_path}" log --name-status -1 |grep "^[ADM][[:blank:]][[:blank:]]*" ${rev} |
while read mline
do
	_action="$(echo "${mline}"|sed -e "s/[^ADM].*$//")"
	_filepath="$(echo "${mline}"|sed -e "s/^[ADM][[:blank:]][[:blank:]]*//")"
	echo -n "${_action} : ${_filepath} -> "
	if [ "A" = "${_action}" ] || [ "M" = "${_action}" ];then
		echo "new : ${patch_name}/${_filepath}"
		cd "${patch_name}"
		git checkout -- "${_filepath}" ${rev}
		cd "${work_dir}"
	elif [ "D" = "${_action}" ];then
		echo "${_filepath} >> ${patch_name}.del"
		echo "${_filepath}" >> "${patch_name}.del"
	fi
done

rm -f "${patch_name}/.git"

exit 0

