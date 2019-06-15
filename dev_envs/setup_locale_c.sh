SEL_LOCALE="DEFAULT"

SET_LOCALE_TO=$1


if [ -z "${SET_LOCALE_TO}" ];then
	export LANG="zh_TW.UTF-8"
	export LANGUAGE="zh_TW:zh"
	export LC_CTYPE="zh_TW.UTF-8"
	export LC_NUMERIC="zh_CN.UTF-8"
	export LC_TIME="zh_TW.UTF-8"
	export LC_COLLATE="zh_TW.UTF-8"
	export LC_MONETARY="zh_CN.UTF-8"
	export LC_MESSAGES="zh_TW.UTF-8"
	export LC_PAPER="zh_CN.UTF-8"
	export LC_NAME="zh_CN.UTF-8"
	export LC_ADDRESS="zh_CN.UTF-8"
	export LC_TELEPHONE="zh_CN.UTF-8"
	export LC_MEASUREMENT="zh_CN.UTF-8"
	export LC_IDENTIFICATION="zh_CN.UTF-8"
	export LC_ALL=
else

	if [ -z "$(localectl list-locales|grep "${SET_LOCALE_TO}")" ];then
		printf "locale \"${SET_LOCALE_TO}\" not exist !!\n" 1>&2
		SET_LOCALE_TO="en_US.utf8"
	fi

	export LANG="${SET_LOCALE_TO}"
	export LANGUAGE="${SET_LOCALE_TO}"
	export LC_CTYPE="${SET_LOCALE_TO}"
	export LC_NUMERIC="${SET_LOCALE_TO}"
	export LC_TIME="${SET_LOCALE_TO}"
	export LC_COLLATE="${SET_LOCALE_TO}"
	export LC_MONETARY="${SET_LOCALE_TO}"
	export LC_MESSAGES="${SET_LOCALE_TO}"
	export LC_PAPER="${SET_LOCALE_TO}"
	export LC_NAME="${SET_LOCALE_TO}"
	export LC_ADDRESS="${SET_LOCALE_TO}"
	export LC_TELEPHONE="${SET_LOCALE_TO}"
	export LC_MEASUREMENT="${SET_LOCALE_TO}"
	export LC_IDENTIFICATION="${SET_LOCALE_TO}"
	export LC_ALL="${SET_LOCALE_TO}"

fi

