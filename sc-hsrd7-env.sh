
export REMOTE_USER=gallen
export REMOTE_HOST=192.168.101.12
export REMOTE_AOSP_MIRROR=/mnt/android_fw_images/mtk/android16_mirror
export REMOTE_AOSP_BASE=/mnt/ntx_user3/overlayfs/mtk/android16_base
export REMOTE_AOSP_OVERLAY=/mnt/ntx_user3/overlayfs/${REMOTE_USER}/mtk16_nb
export REMOTE_OVERLAY_NAME=mtk16
export REMOTE_AOSP_OVERLAY_UPPER=/mnt/ntx_user3/overlayfs/${REMOTE_USER}/mtk16_nb/mtk16-upper
export REMOTE_AOSP_OVERLAY_WORK=/mnt/ntx_user3/overlayfs/${REMOTE_USER}/mtk16_nb/mtk16-work
export REMOTE_AOSP_OVERLAY_MERGE=/mnt/ntx_user3/overlayfs/${REMOTE_USER}/mtk16_nb/mtk16
export REMOTE_DOCKER_CONTAINER=aosp16_build_base
export GIT_USERNAME=${REMOTE_USER}
export GIT_USERMAIL=gallen.lin@netronixinc.com
export LOCAL_ADB_PORT=5037
export START_REMOTE_PORT=15037

