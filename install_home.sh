#!/bin/bash

if [ -z "$(which dialog)" ];then
	sudo apt-get install dialog 
fi

work_dir="$(pwd)"
#"

install_bashrc_custom() {
	addstr=". ~/.bashrc_custom"
	
	if [ ! -f "${HOME}/.bashrc" ] || [ "$(cat "${HOME}/.bashrc")" ];then
		echo "${HOME}/.bashrc not found or empty !!!"
		lsb_id="$(lsb_release -i|awk -F: '{print $2}'|awk '{print $1}')"
		lsb_rev="$(lsb_release -r|awk -F: '{print $2}'|awk '{print $1}')"
		lsb_rev_major="$(echo "${lsb_rev}"|awk -F. '{print $1}')"
		if [ "${lsb_id}" ];then
			if [ -e "bashrc.${lsb_id}-r${lsb_rev}" ];then
				cp -v "bashrc.${lsb_id}-r${lsb_rev}" "${HOME}/.bashrc"
			elif [ -e "bashrc.${lsb_id}-r${lsb_rev_major}" ];then
				cp -v "bashrc.${lsb_id}-r${lsb_rev_major}" "${HOME}/.bashrc"
			else
				echo "new ${lsb_id} revision ${lsb_rev_major} should be added !!"
				read -p "press enter to continue ." ans
				cp -v bashrc.ubuntu1204 "${HOME}/.bashrc"
				cp -v "${HOME}/.bashrc" "bashrc.${lsb_id}-r${lsb_rev_major}"
				chmod +x "bashrc.${lsb_id}-r${lsb_rev_major}"
			fi
		else
			cp -v bashrc.ubuntu1204 "${HOME}/.bashrc"
		fi
	fi

	if [ -z "$(cat ~/.bashrc|grep "${addstr}")" ];then
		echo "" >> ~/.bashrc
		echo "${addstr}" >> ~/.bashrc
		echo "" >> ~/.bashrc
	fi

	return 0
}

install_files_to_home() {
	find -maxdepth 1|grep -v "bin$"|grep -v "\.ssh"|grep -v "\.svn"|grep -v "\.hg"|grep -v "\.git"|grep -v "\.$"|grep -v "\.\.$"|grep -v ".*~$"|grep -v ".*swp$"|grep -v "$(basename ${0})"| 
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


	# setup all file and directory permission naming .ssh* ...
	find |grep .ssh.* | 
	while read ssh_fdesc 
	do 
		if [ -L "${HOME}/${ssh_fdesc}" ];then
			# do nothing if .ssh* exist as a symbolic link . 
			echo "WARNING : ${HOME}/${ssh_fdesc} is a symbolic link"
		elif [ -d "${HOME}/${ssh_fdesc}" ];then
			cp -a .${ssh_fdesc}/* ${HOME}/${ssh_fdesc}/
		else
			# if .ssh* not exist we can choose create symbolic or copy file into a new one . 
			method="symbolic" # new | symbolic 
			if [ "${method}" = "new" ];then
				mkdir "${HOME}/${ssh_fdesc}"
				cp -a .${ssh_fdesc}/* ${HOME}/${ssh_fdesc}/
			else
				ln -s "${work_dir}/${ssh_fdesc}" "${HOME}/"
			fi
		fi

		if [ -d "${HOME}/${ssh_fdesc}" ];then
			chmod 700 "${HOME}/${ssh_fdesc}"
			chmod 600 "${HOME}/${ssh_fdesc}/id_rsa"
			chmod 644 "${HOME}/${ssh_fdesc}/id_rsa.pub"
		fi
	done

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


