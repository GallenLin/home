#!/bin/bash
git st |grep "^#[[:blank:]]*deleted:"|sed -e "s/^#[[:blank:]]*deleted:[[:blank:]]*//" |
while read _rmf
do
	git rm "${_rmf}"
done

