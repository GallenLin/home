#!/bin/bash

# this tool make your git repostory become writable and public .

for git_repo_dir in $*
do
	cd "$git_repo_dir"

	# 1. (for git clone/fetch) modify .git/config in core section : bare = true 
	git config core.bare true

	# 1.1 (for git push) == git --shared .
	git config core.sharedrepository 1
	git config receive.denyNonFastforwards true

	# 2. (for http) run 'git update-server-info'
	git update-server-info

	# 3. (for git push/clone) cp .git/hooks/post-update.sample .git/hooks/post-update
	if [ -d ".git" ];then
		cp ".git/hooks/post-update.sample" ".git/hooks/post-update"
	else
		cp "hooks/post-update.sample" "hooks/post-update"
	fi

	cd -
done


