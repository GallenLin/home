#!/bin/bash

#
# this tool help you to create unique revision like SVN as GIT tag .
#
# the revision tag name rule : [prefix][revision number][suffix] .
#    [prefix] : always should be 'r' .
#    [revision number] : a dec digit number >=1 ,this revision is always
#        unique in this repository even you created in other branch .
#    [suffix] : _[branch] ,[branch] should be combination of digit (0-9) or alpha(a-z,A-Z) or '.' .
#    
#        if there are some branchs in your repository :
#                base
#                base.mx50
#                base.m166e
#                base.mx50.E60612
#                base.mx50.E60622
#                base.mx50.E60622.NB
#                base.mx50.E60622.GB
#                base.mx50.E60612.kobo
#                base.m166e.E60M32
#                base.m166e.E60M32.kobo
#    
#        so the tag name that created by this tool will like following :
#                r1_base
#                r2_base.mx50
#                r3_base.mx50.E60612
#                r4_base.mx50
#                r5_base.mx50.E60622
#                r6_base.mx50.E60622.NB
#                r7_base.mx50.E60622.GB
#                r8_base.mx50.E60612.kobo
#                r9_base.m166e.E60M32.kobo
#                ...
#
# 
#


cur_branch="$(git branch|grep ^*|sed -e "s/^*[[:blank:]]*//")"
rev_prefix="r"
#rev_suffix="$(echo "${cur_branch}"|sed -e "s/[[:print:]]*\.//g")"
rev_suffix="$(echo "${cur_branch}")"

last_rev_tag="$(git tag|sed -e "s/^${rev_prefix}//"|sort -g|grep "^[[:digit:]][[:digit:]]*_[[:alnum:]][[:alnum:]\.]*$"|tail -n 1|sed -e "s/^/${rev_prefix}/")"

if [ "${last_rev_tag}" ];then
	last_rev_num="$(echo "${last_rev_tag}"|sed -e "s/^${rev_prefix}//"|sed -e "s/_[[:alnum:]\.]*$//")"
	next_rev_num="$(expr ${last_rev_num} + 1)"
else 
	next_rev_num="1"
fi
next_rev_tag="${rev_prefix}${next_rev_num}_${rev_suffix}"

if [ -z "${last_rev_tag}" ] || [ "$(git show --pretty=raw "${last_rev_tag}"|head -n 1)" != "$(git log -1 --pretty=raw |head -n1)" ];then
	echo "new revision tag=\"${next_rev_tag}\""
	git tag "${next_rev_tag}"
else
	echo "you can get tag \"${last_rev_tag}\" !"
fi

exit 0

