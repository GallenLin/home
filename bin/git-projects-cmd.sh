#!/bin/bash

usage() {
	cat >&2 <<- EOF
	****************************************************************
	perform command for each git project .

	 Usage: ${0} [OPTIONS] [GITSPATH] [GITPROJ] ...
	
	[GITSPATH] :
	  the top path of git projects . 

	[OPTIONS] :
	 -c "<GITCMD>" :  perform git command in each git project .
	 	<GITCMD> : eg , git status , git branch ...

	 -m "<MIRROR_PATH>" :  clone git projects become mirrors repository .
	 	<MIRROR_PATH> : mirror path which you want to create .

	 -M "<REPO_PATH>" :  move git repository into REPO_PATH.
	 	<REPO_PATH> : repo path which you want to create .

	 -C "<REPO_PATH>" :  copy git repository into REPO_PATH.
	 	<REPO_PATH> : repo path which you want to create .

	 -R "<WORK_PATH>" :  restore git repository into WORK_PATH.
	 	<WORK_PATH> : work path which you want to restore git repo .

	 -L "<WORK_PATH>" :  link git repository into WORK_PATH.
	 	<WORK_PATH> : work path which you want to link with .

	[GITPROJ] :
	 git project folder ,if this field empty ,this tool will search 
	 projects in [GITSPATH] .

	Examples :

	 --> check each git projects status in this folder,
	      It's useful to check projects status in android repo . 

	     ${0} -c "git status"

	 --> create each git projects in mirror path .

	     ${0} -m ../mirror

	 --> move each git projects to new path .

	     ${0} -M ../new-path

	 --> copy each git projects to new path .

	     ${0} -B ../new-path

	 --> restore repositories to exist work dir .

	     ${0} -R ../work-dir
			 

	****************************************************************
	EOF
	return 0
}


repo_action() {

	extra_msg=""
	is_work_dir=0

	_git_repo_dir="$1"
	_cur_dir="$(pwd)"

	TOTAL_PROJECTS="$(expr ${TOTAL_PROJECTS} + 1)"
	cd "${_git_repo_dir}"
	if [ "$(echo "${_git_repo_dir}"|grep "\/\.git$")" ];then
		# this is git working folder ...
		_git_work_dir="$(dirname "${_git_repo_dir}")"
		_git_proj_name="$(basename "${_git_work_dir}")"
		echo "[${TOTAL_PROJECTS}. WORK \"${_git_proj_name}\"] ${_git_work_dir} : "
		cd ".."
		is_work_dir=1
	else
		# this is pure git repository ...
		_git_work_dir="${_git_repo_dir}"
		_git_proj_name="$(basename "${_git_repo_dir}" .git)"
		echo "[${TOTAL_PROJECTS}. REPO \"${_git_proj_name}\"] ${_git_repo_dir} : "
		is_work_dir=0
	fi
	_git_repo_full_path="$(pwd)"

	case "${CMD_TYPE}" in

		"regular_cmd" )
			eval ${RUN_CMD}
			;;

		"mv_repo" )
			cd "${DIST_PATH}"
			_mirror_rel_path="$(echo "${_git_repo_dir}"|sed -e "s/\/[^\/]*$//")"
			mkdir -p "${_mirror_rel_path}"
			cd "${_mirror_rel_path}"
			
			echo "move repo : \"$(pwd)\" <- \"${_git_repo_full_path}\" ... "
			if [ ${is_work_dir} = 1 ];then
				mv "${_git_repo_full_path}/.git" "./"
			else
				mv "${_git_repo_full_path}" "./"
			fi
			extra_msg=" has been move into \"${DIST_PATH}\""

			cd "${_git_repo_full_path}"
			;;

		"cp_repo" )
			cd "${DIST_PATH}"
			_mirror_rel_path="$(echo "${_git_repo_dir}"|sed -e "s/\/[^\/]*$//")"
			mkdir -p "${_mirror_rel_path}"
			cd "${_mirror_rel_path}"

			echo "copy repo : \"$(pwd)\" <- \"${_git_repo_full_path}\" ... "
			if [ ${is_work_dir} = 1 ];then
				cp -a "${_git_repo_full_path}/.git" "./"
			else
				cp -a "${_git_repo_full_path}" "./"
			fi
			extra_msg=" has been copy into \"${DIST_PATH}\""

			cd "${_git_repo_full_path}"
			;;

		"restore_repo" )
			cd "${DIST_PATH}"
			_restore_rel_path="$(echo "${_git_repo_dir}"|sed -e "s/\/[^\/]*$//")"
			cd "${_restore_rel_path}"

			echo "restore repo : \"$(pwd)\" <- \"${_git_repo_full_path}\" ... "
			if [ ${is_work_dir} = 1 ];then
				cp -a "${_git_repo_full_path}/.git" "./"
			else
				cp -a "${_git_repo_full_path}" "./"
			fi
			extra_msg=" has been restore into \"${DIST_PATH}\""

			cd "${_git_repo_full_path}"
			;;

		"link_repo" )
			cd "${DIST_PATH}"
			_restore_rel_path="$(echo "${_git_repo_dir}"|sed -e "s/\/[^\/]*$//")"
			cd "${_restore_rel_path}"

			echo "link repo : \"$(pwd)\" <- \"${_git_repo_full_path}\" ... "
			if [ ${is_work_dir} = 1 ];then
				ln -s "${_git_repo_full_path}/.git" "./.git"
			else
				ln -s "${_git_repo_full_path}" "./.git"
			fi
			extra_msg=" has been link into \"${DIST_PATH}\""

			cd "${_git_repo_full_path}"
			;;

		"mirror" )
			cd "${DIST_PATH}"
			_mirror_rel_path="$(echo "${_git_repo_dir}"|sed -e "s/\/[^\/]*$//")"
			mkdir -p "${_mirror_rel_path}"
			cd "${_mirror_rel_path}"

			echo "clone : \"$(pwd)\" <- \"${_git_repo_full_path}\" ... "
			git clone --mirror "file://${_git_repo_full_path}"
			extra_msg=" has been clone into \"${DIST_PATH}\""

			cd "${_git_repo_full_path}"
			;;


		* )
			echo "unsupported cmd type - \"${CMD_TYPE}\""
			;;
	esac


	cd "${_cur_dir}"

	echo ""

		#sed -i "s/:.*$/: ${new_ref2}/g" $_git_repo_dir/HEAD
		#echo "$_git_repo_dir/HEAD : $(sed -e "s/ref://" $_git_repo_dir/HEAD) -> ${new_ref}"
}

repos_action() {

	export TOTAL_PROJECTS="0"
	export extra_msg=""

	#new_ref2="$(echo "$new_ref" |sed "s/\//\\\\\//g")"


	if [ "$*" ];then

		for _repo_dir in $@
		do
			#cat "$_git_repo_dir/HEAD"
			repo_action "${_repo_dir}"
		done

	else

		find |grep "\.git$"|grep -v "\.repo" > ${tmpfile}-repolist
		while read _repo_dir 
		do
			#cat "$_git_repo_dir/HEAD"
			repo_action "${_repo_dir}"
		done < ${tmpfile}-repolist

	fi

	echo "${TOTAL_PROJECTS} projects in \"${PROJS_TOP_DIR}\" ${extra_msg}"
	echo ""

	return 0	
}

work_dir="$(pwd)"
id_str="$(date +%Y%m%d%H%M%S)"
tmpfile="/tmp/tmp-${id_str}"


_opt_dec=1
while getopts "c:m:M:C:R:L:h" opt
do
	case ${opt} in
		c )
			RUN_CMD="${OPTARG}"
		  CMD_TYPE="regular_cmd"
			;;
		m )
		  CMD_TYPE="mirror"
			if [ -d "${OPTARG}" ];then
				echo "path \"${OPTARG}\" already exist !"
				exit 0
			fi
			mkdir -p "${OPTARG}"
			cd "${OPTARG}"
			DIST_PATH="$(pwd)"
			cd -
			;;
		M )
		  CMD_TYPE="mv_repo"
			if [ -d "${OPTARG}" ];then
				echo "path \"${OPTARG}\" already exist !"
				exit 0
			fi
			mkdir -p "${OPTARG}"
			cd "${OPTARG}"
			DIST_PATH="$(pwd)"
			cd -
			;;
		C )
		  CMD_TYPE="cp_repo"
			if [ -d "${OPTARG}" ];then
				echo "path \"${OPTARG}\" already exist !"
				exit 0
			fi
			mkdir -p "${OPTARG}"
			cd "${OPTARG}"
			DIST_PATH="$(pwd)"
			cd -
			;;
		R )
		  CMD_TYPE="restore_repo"
			if [ ! -d "${OPTARG}" ];then
				echo "path \"${OPTARG}\" do not exist !"
				exit 0
			fi
			cd "${OPTARG}"
			DIST_PATH="$(pwd)"
			cd -
			;;
		L )
		  CMD_TYPE="link_repo"
			if [ ! -d "${OPTARG}" ];then
				echo "path \"${OPTARG}\" do not exist !"
				exit 0
			fi
			cd "${OPTARG}"
			DIST_PATH="$(pwd)"
			cd -
			;;
		h )
			usage
			exit 0 
			;;
		\? ) 
			usage 
			exit 0 
			;;
	esac
done
shift "$(expr ${OPTIND} - ${_opt_dec})"




PROJS_TOP_DIR="${1}"
TOTAL_PROJECTS=0

if [ -z "${PROJS_TOP_DIR}" ];then
	PROJS_TOP_DIR="${work_dir}"
else
	cd "${PROJS_TOP_DIR}"
fi
shift 


repos_action $*

rm -f ${tmpfile}*

exit 0


