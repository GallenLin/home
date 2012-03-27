#!/bin/bash

mygitcfg_alias()
{

	git config --global alias.co checkout
	git config --global alias.ci commit
	git config --global alias.st status
	git config --global alias.br branch
	git config --global alias.up "submodule update --init --recursive"

	return 0
}

git config --global user.name Gallen
git config --global user.email gallen.lin@netronixinc.com

mygitcfg_alias

git config --global color.ui true


