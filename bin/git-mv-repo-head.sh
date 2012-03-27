#!/bin/bash

usage() {
	echo ""
	echo "this tool change your HEAD of git's repo "
	echo "Usage : "
	echo " $0 [symref]"
	echo "  [symref] : eg, refs/heads/master (default) "
	echo ""
}

new_ref="$1"

#_git_repo_dir="./"

if [ -z "${new_ref}" ];then
	new_ref="refs/heads/master"
fi


if [ -z "$(git show-ref --heads|grep "${new_ref}$")" ];then
	echo "\"${new_ref}\" not exist !"
	usage
	exit 1
fi

echo "HEAD -> ${new_ref}"
git symbolic-ref HEAD "${new_ref}"

#new_ref2="$(echo "${new_ref}" |sed "s/\//\\\\\//g")"
#sed -i "s/:.*$/: ${new_ref2}/g" ${_git_repo_dir}/HEAD

exit 0

