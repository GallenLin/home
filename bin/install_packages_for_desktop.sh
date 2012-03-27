#!/bin/bash

# test in ubuntu 10.04 .
add_apt_source() {
	apt_source="$1"
	apt_source_list_file="/etc/apt/sources.list"
	if [ -z "$(cat "${apt_source_list_file}"|grep "${apt_source}")" ];then
		sudo -s "echo "${apt_source}" >> "${apt_source_list_file}""
	fi
	return 0
}

add_apt_packages_source()
{
	# xbmc ppa source 
	sudo add-apt-repository ppa:team-xbmc

	# skype ppa source .
	sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 0xd66b746e
	add_apt_source "deb http://download.skype.com/linux/repos/debian/ stable non-free"

	# pps ppa source
	sudo add-apt-repository ppa:portis25/ppa
	sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 27F5B2C1B3EAC8D9

	# update all sources 
	sudo apt-get -y update
	return 0
}

add_apt_packages_source

# ubuntu 
sudo apt-get -y install unrar lha p7zip-full p7zip-rar poppler-data gstreamer0.10-ffmpeg gstreamer0.10-plugins-bad gstreamer0.10-plugins-ugly flashplugin-installer
# 
sudo sed -i '/DejaVu/d ; /Bitstream Vera/d ; /WenQuanYi Bitmap Song/d' /etc/fonts/conf.avail/69-language-selector-*
sudo apt-get -y install compiz-fusion-plugins-extra simple-ccsm compizconfig-settings-manager
sudo apt-get -y install smbfs
# text mode browser ...
sudo apt-get -y install links
# camera about .
sudo apt-get -y install cheese


# skype packages ...
#For 32-bit
#wget http://www.skype.com/go/getskype-linux-beta-ubuntu-32
#For 64-bit
#wget http://www.skype.com/go/getskype-linux-beta-ubuntu-64
sudo apt-get -y install libqt4-dbus libqt4-network libqt4-xml libasound2
sudo apt-get -y install skype*

# input method .
sudo apt-get -y install scim scim-gtk2-immodule scim-modules-socket scim-tables-zh scim-chewing scim-chinese 
sudo apt-get -y install gcin

# xbmc for ubuntu .
sudo apt-get -y install python-software-properties pkg-config
sudo apt-get -y install xbmc xbmc-standalone

# smplayer
sudo apt-get -y install smplayer 

# pps
sudo apt-get install ppstream


