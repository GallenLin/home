#!/bin/bash

mygitcfg_alias()
{

	git config --global alias.co checkout
	git config --global alias.ci commit
	git config --global alias.st status
	git config --global alias.br branch
	git config --global alias.up "submodule update --init --recursive"

	# 
	git config --global alias.glog "log --topo-order --pretty=fuller"
	# git glog 會秀出committer & author , 並按每個線的時間順序排列

	git config --global alias.meld-diff "diff GIT_EXTERNAL_DIFF=git-meld"
	return 0
}

git config --global user.name Gallen
git config --global user.email gallen.lin@netronixinc.com

mygitcfg_alias

git config --global color.ui true

# use meld as diff tool .
# git config --global diff.external git-meld
# git config --unset diff.external 


#git config --global diff.tool vimdiff
#git config --global difftool.prompt No

# 解決 “fatal: The remote end hung up unexpectedly” 的問題。
git config --global uploadpack.keepAlive 60
#  When upload-pack has started pack-objects, there may be a quiet period while pack-objects prepares the pack. Normally it would output progress information, but if --quiet was used for the fetch, pack-objects will output nothing at all until the pack data begins. Some clients and networks may consider the server to be hung and give up. Setting this option instructs upload-pack to send an empty keepalive packet every uploadpack.keepAlive seconds. Setting this option to 0 disables keepalive packets entirely. The default is 5 seconds. 

########################
# 為解決 out of memory 
# fatal: Out of memory, malloc failed (tried to allocate xxxx bytes)
#
git config --global pack.threads 1
git config --global pack.deltaCacheSize 128m
git config --global pack.windowMemory 50m
########################
# 為解決 
# fatal: git upload-pack: aborting due to possible repository corruption on the remote side.
# 
git config --global pack.window 0




