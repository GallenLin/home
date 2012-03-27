#!/bin/bash
work_dir="$(pwd)"
clone_url="$1"

if [ -d ".git" ];then
	echo "\".git\" existed !"
	exit 1
fi

if [ -z "${clone_url}" ];then
	echo "url cannot empty !"
	exit 1
fi

git init
git remote add origin "${clone_url}"
git config branch.master.remote origin 
git config branch.master.merge master
git pull

exit 0

