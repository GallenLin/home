#!/bin/bash

SHELL_LIB_PATH="$HOME/bin"

. ${SHELL_LIB_PATH}/mount_helper.sh

#NETRONIX_RDPUB_IP="192.168.20.51"
NETRONIX_RDPUB_IP="192.168.20.247"



## mount ebk share folder ...

function mount_ntx_ebk() {
	mount_cifs "${NETRONIX_RDPUB_IP}" "eBook" "${HOME}/ebk" root
}

function mount_ntx_ebk2() {
	mount_cifs "${NETRONIX_RDPUB_IP}" "eBook2" "${HOME}/ebk2" root
}

## mount netronix repostory ...
function mount_ntx_svn_repos() {
	mount_cifs "${NETRONIX_RDPUB_IP}" "svn_repos" "${HOME}/svn_repos" root
}
function mount_ntx_git_repos() {
	mount_cifs "${NETRONIX_RDPUB_IP}" "git_repos" "${HOME}/git_repos" root
}

function mount_vbox_vmshare() {
	## mount virtualbox share folder ...
	if [ "$(which mount.vboxsf)" != "" ];then
		MYVBOXSHAREFLD="$HOME/vboxshare"
		mountpt_check $MYVBOXSHAREFLD
		if [ "$?" = "1" ];then
			echo "mount from vmshare to $MYVBOXSHAREFLD ..."
			sudo mount.vboxsf vmshare $MYVBOXSHAREFLD
			if [ $? = "0" ];then
				echo "[done]"
			else
				echo "[fail]"
				return 1
			fi
		fi
	fi
	return 0
}


function mount_vmware_vmshare() {
	vmshare_name="$1"

	## mount vmware share folder ...
	if [ "$(which mount.vmhgfs)" != "" ];then
		my_vm_share_fld="$HOME/vmshares"
		mountpt_check "${my_vm_share_fld}/${vmshare_name}"
		if [ "$?" = "1" ];then
			echo "mount from ${vmshare_name} to ${my_vm_share_fld}/${vmshare_name} ..."
			sudo mount -o ttl=3 -t vmhgfs .host:/${vmshare_name} "${my_vm_share_fld}/${vmshare_name}"
			if [ $? = "0" ];then
				echo "[done]"
			else
				echo "[fail]"
				return 1
			fi
		fi
	fi

	return 0
}



