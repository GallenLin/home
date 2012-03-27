#!/bin/bash

#alias la='ls -a --color=auto'

SHELL_LIB_PATH="${HOME}/bin"
. ${SHELL_LIB_PATH}/workenv.sh

#mount_vmware_vmshare
#mount_vbox_vmshare
mount_ntx_ebk
mount_ntx_ebk2
mount_ntx_svn_repos
mount_ntx_git_repos

## 


