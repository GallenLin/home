#!/bin/bash

SVNST_FULL_FILE=".svn-status.txt"
SVNST_FILTER_FILE=".svn-status-filted.txt"

#IGNORE_LIST="\.10089\.tmp \.tmp_System\.map \.tmp_kallsyms1\.S \.tmp_kallsyms2\.S \.tmp_vmlinux1 \.tmp_vmlinux2 vmlinux \.tmp_versions kernel\/config_data\.gz kernel\/config_data\.h arch\/arm\/boot\/Image arch\/arm\/boot\/uImage arch\/arm\/boot\/compressed\/piggy\.gz arch\/arm\/boot\/compressed\/vmlinux include\/config ${SVNST_FULL_FILE} ${SVNST_FILTER_FILE}"


cat ${SVNST_FULL_FILE} |grep -v '\.cmd'|grep -v '\.ko'|grep -v '\.mod\.c'|grep -v '\.order'|grep -v '\.builtin' > ${SVNST_FILTER_FILE}
sync

for i in ${IGNORE_LIST} 
do
 	echo "====remove $i======="	
	cat ${SVNST_FILTER_FILE} |grep -v "$i" > ${SVNST_FILTER_FILE}
	sync
	cat ${SVNST_FILTER_FILE}
done

cat ${SVNST_FILTER_FILE}

