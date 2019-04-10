#!/bin/bash



work_dir="$(pwd)"
#"

install_bashrc_custom() {
	addstr=". ~/.bashrc_custom"
	
	if [ ! -f "${HOME}/.bashrc" ] || [ "$(cat "${HOME}/.bashrc")" ];then
		echo "${HOME}/.bashrc not found or empty !!!"
		cp bashrc.ubuntu1204 "${HOME}/.bashrc"
	fi

	if [ -z "$(cat ~/.bashrc|grep "${addstr}")" ];then
		echo "" >> ~/.bashrc
		echo "${addstr}" >> ~/.bashrc
		echo "" >> ~/.bashrc
	fi

	return 0
}

install_files_to_home() {
	find -maxdepth 1|grep -v "\.ssh"|grep -v "\.svn"|grep -v "\.hg"|grep -v "\.git"|grep -v "\.$"|grep -v "\.\.$"|grep -v ".*~$"|grep -v ".*swp$"|grep -v "$(basename ${0})"| 
	while read _path
	do
		if [ -f "${HOME}/${_path}" ];then
			LANG=C dialog --ascii-lines --title "${_path} in ${HOME} is existed" \
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
				ln -s "${work_dir}/${_path}" "${HOME}/"
				;;
			1)
				echo "Abort chosen."
				return 1
				;;
			2)
				echo "Help pressed.";;
			3)
				echo "Keep pressed.";;
				
			255)
				echo "ESC pressed."
				return 1
				;;
			esac

		elif [ -d "${HOME}/${_path}" ];then
			echo "skip folder \"${HOME}/${_path}\""
		else
			echo "${work_dir}/${_path} -> ${HOME}/"
			ln -s "${work_dir}/${_path}" "${HOME}/"
		fi
		
	done

	if [ -L "${HOME}/.ssh" ];then
		echo "WARNING : ${HOME}/.ssh is a symbolic link"
	elif [ -d "${HOME}/.ssh" ];then
		cp -a .ssh/* ${HOME}/.ssh/
	else
		mkdir "${HOME}/.ssh"
	fi

	chmod 700 "${HOME}/.ssh"
	chmod 600 "${HOME}/.ssh/id_rsa"
	chmod 644 "${HOME}/.ssh/id_rsa.pub"

	return 0
}


install_hgrc() {
	if [ ! -f "${HOME}/.hgrc" ];then
		echo "install .hgrc into your home ."
		ln -s ${work_dir}/.hgrc "${HOME}/.hgrc"
	fi
	return 0
}

install_hgrc

install_files_to_home
[ $? != 0 ] && echo "install files to home fail !" && exit 1

install_bashrc_custom
exit $?


