#!/bin/bash

if ! command -v dialog >/dev/null 2>&1;then
	sudo apt-get install dialog 
fi

work_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#"

install_bashrc_custom() {
	addstr=". ~/.bashrc_custom"
	if command -v lsb_release >/dev/null 2>&1;then
		lsb_id="$(lsb_release -i|awk -F: '{print $2}'|awk '{print $1}')"
		lsb_rev="$(lsb_release -r|awk -F: '{print $2}'|awk '{print $1}')"
		lsb_rev_major="$(echo "${lsb_rev}"|awk -F. '{print $1}')"
	else
		lsb_id=""
		lsb_rev=""
		lsb_rev_major=""
	fi

	if [ ! -s "${HOME}/.bashrc" ];then
		echo "${HOME}/.bashrc not found or empty !!!"
		if [ "${lsb_id}" ];then
			if [ -e "${work_dir}/bashrc.${lsb_id}-r${lsb_rev}" ];then
				cp -v "${work_dir}/bashrc.${lsb_id}-r${lsb_rev}" "${HOME}/.bashrc"
			elif [ -e "${work_dir}/bashrc.${lsb_id}-r${lsb_rev_major}" ];then
				cp -v "${work_dir}/bashrc.${lsb_id}-r${lsb_rev_major}" "${HOME}/.bashrc"
			else
				echo "new ${lsb_id} revision ${lsb_rev_major} should be added !!"
				read -p "press enter to continue ." ans
				cp -v "${work_dir}/bashrc.ubuntu1204" "${HOME}/.bashrc"
			fi
		else
			cp -v "${work_dir}/bashrc.ubuntu1204" "${HOME}/.bashrc"
		fi
	fi

	if ! grep -Fxq "${addstr}" "${HOME}/.bashrc";then
		echo "" >> "${HOME}/.bashrc"
		echo "${addstr}" >> "${HOME}/.bashrc"
		echo "" >> "${HOME}/.bashrc"
	fi

	return 0
}

install_files_to_home() {
	local install_items=(
		".bashrc-ubuntu10.04-default"
		".bashrc_custom"
		".gitignore"
		".hgignore"
		".tmux.conf"
		".vim"
		".vimrc"
		"bashrc.Linuxmint-r20"
		"bashrc.Linuxmint-r21"
		"bashrc.Linuxmint-r22"
		"bashrc.Raspbian-r20"
		"bashrc.ubuntu1204"
		"chitailintv@gmail.com.muttrc"
		"sc-hsrd7-env.sh"
	)
	local _path

	for _path in "${install_items[@]}"
	do
		if [ ! -e "${work_dir}/${_path}" ];then
			echo "skip missing \"${work_dir}/${_path}\""
			continue
		fi

		if [ -e "${HOME}/${_path}" ] || [ -L "${HOME}/${_path}" ];then
			if [ -d "${HOME}/${_path}" ] && [ ! -L "${HOME}/${_path}" ];then
				echo "skip folder \"${HOME}/${_path}\""
				continue
			fi

			LANG=C dialog --ascii-lines --title "${_path} in ${HOME} is existed" \
			--clear \
			--ok-label "Overwrite" \
			--no-label "Abort" \
			--extra-label "Keep" --extra-button \
			--yesno "File/Folder named \"$(basename "${_path}")\" in \"${HOME}\" is existed . \
									 What you want to do ? " 15 61
			case $? in
			0)
				echo "Overwrite chosen."
				rm -f "${HOME}/${_path}"
				ln -s "${work_dir}/${_path}" "${HOME}/${_path}"
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
		else
			echo "${work_dir}/${_path} -> ${HOME}/${_path}"
			ln -s "${work_dir}/${_path}" "${HOME}/${_path}"
		fi
		
	done


	# setup all file and directory permission naming .ssh* ...
	find "${work_dir}" -maxdepth 1 -type d -name '.ssh*' -print |
	while IFS= read -r ssh_src
	do 
		ssh_fdesc="$(basename "${ssh_src}")"
		if [ -L "${HOME}/${ssh_fdesc}" ];then
			# do nothing if .ssh* exist as a symbolic link . 
			echo "WARNING : ${HOME}/${ssh_fdesc} is a symbolic link"
		elif [ -d "${HOME}/${ssh_fdesc}" ];then
			cp -a "${ssh_src}/." "${HOME}/${ssh_fdesc}/"
		else
			# if .ssh* not exist we can choose create symbolic or copy file into a new one . 
			method="symbolic" # new | symbolic 
			if [ "${method}" = "new" ];then
				mkdir "${HOME}/${ssh_fdesc}"
				cp -a "${ssh_src}/." "${HOME}/${ssh_fdesc}/"
			else
				ln -s "${ssh_src}" "${HOME}/${ssh_fdesc}"
			fi
		fi

		if [ -d "${HOME}/${ssh_fdesc}" ] && [ ! -L "${HOME}/${ssh_fdesc}" ];then
			chmod 700 "${HOME}/${ssh_fdesc}"
			[ -f "${HOME}/${ssh_fdesc}/id_rsa" ] && chmod 600 "${HOME}/${ssh_fdesc}/id_rsa"
			[ -f "${HOME}/${ssh_fdesc}/id_rsa.pub" ] && chmod 644 "${HOME}/${ssh_fdesc}/id_rsa.pub"
		fi
	done

	return 0
}


install_ssh_keypairs() {
	local archive="${work_dir}/gallen-D900TA-ssh-keypairs.tgz"
	local ssh_dir="${HOME}/.ssh"

	if [ ! -f "${archive}" ];then
		echo "skip missing \"${archive}\""
		return 0
	fi

	if [ -e "${ssh_dir}" ] && [ ! -d "${ssh_dir}" ];then
		echo "${ssh_dir} exists but is not a directory"
		return 1
	fi

	mkdir -p "${ssh_dir}"

	if [ -e "${ssh_dir}/id_rsa" ] || [ -e "${ssh_dir}/id_rsa.pub" ];then
		LANG=C dialog --ascii-lines --title "ssh keypairs in ${ssh_dir} are existed" \
		--clear \
		--ok-label "Overwrite" \
		--no-label "Abort" \
		--extra-label "Keep" --extra-button \
		--yesno "SSH keypair id_rsa* in \"${ssh_dir}\" is existed . \
								 What you want to do ? " 15 61
		case $? in
		0)
			echo "Overwrite chosen."
			;;
		1)
			echo "Abort chosen."
			return 1
			;;
		2)
			echo "Help pressed.";;
		3)
			echo "Keep pressed."
			return 0
			;;
		255)
			echo "ESC pressed."
			return 1
			;;
		esac
	fi

	echo "${archive} -> ${ssh_dir}/id_rsa*"
	if ! tar -xzf "${archive}" -C "${ssh_dir}" id_rsa id_rsa.pub;then
		echo "extract ${archive} fail !"
		return 1
	fi
	chmod 700 "${ssh_dir}" || return 1
	chmod 600 "${ssh_dir}/id_rsa" || return 1
	chmod 644 "${ssh_dir}/id_rsa.pub" || return 1

	return 0
}


install_hgrc() {
	if [ ! -f "${HOME}/.hgrc" ];then
		echo "install .hgrc into your home ."
		ln -s "${work_dir}/.hgrc" "${HOME}/.hgrc"
	fi
	return 0
}

install_hgrc

install_files_to_home
[ $? != 0 ] && echo "install files to home fail !" && exit 1

install_ssh_keypairs
[ $? != 0 ] && echo "install ssh keypairs fail !" && exit 1

install_bashrc_custom
exit $?
