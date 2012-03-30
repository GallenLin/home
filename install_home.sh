#!/bin/bash

work_dir="$(pwd)"

find -maxdepth 1 |grep -v ".svn" |grep -v ".hg"|grep -v ".git" | 
while read _path
do
	if [ -f "${HOME}/${_path}" ];then
		dialog --title "${_path} in ${HOME} is existed" \
		--clear \
		--ok-label "Overwrite" \
		--no-label "Abort" \
		--extra-label "Keep" --extra-button \
		--yesno "File/Folder named \"$(basename ${_path})\" in \"${HOME}\" is existed . \
                 What you want to do ? " 15 61
		case $? in
  	0)
    	echo "Overwrite chosen."
			rm -f "${HOME}/${_path}"
			echo "ln -s "${work_dir}/${_path}" "${HOME}/""
			;;
  	1)
    	echo "Abort chosen."
			exit 1
			;;
  	2)
    	echo "Help pressed.";;
  	3)
    	echo "Keep pressed.";;
			
  	255)
    	echo "ESC pressed."
			exit 1
			;;
		esac

	elif [ -d "${HOME}/${_path}" ];then
		echo "skip folder \"${HOME}/${_path}\""
	else
		echo "ln -s "${work_dir}/${_path}" "${HOME}/""
	fi
	
done

exit 0


