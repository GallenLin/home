#!/bin/bash
add_apt_source() {
	apt_source="$1"
	apt_source_list_file="/etc/apt/sources.list"
	if [ -z "$(cat "${apt_source_list_file}"|grep "${apt_source}")" ];then
		sudo -s "echo "${apt_source}" >> "${apt_source_list_file}""
	fi
	return 0
}

add_apt_packages_source() {
	# add mercurial ppa source .
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 323293EE
	sudo add-apt-repository ppa:mercurial-ppa/releases
	# add tortoisehg ppa source .
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key D5056DDE
	sudo add-apt-repository ppa:tortoisehg-ppa/releases
	# add RabbitVCS source .

	#if [ -z "$(cat "/etc/apt/sources.list"|grep "deb http://ppa.launchpad.net/rabbitvcs/ppa/ubuntu lucid main")" ];then
	#	sudo -s "echo "deb http://ppa.launchpad.net/rabbitvcs/ppa/ubuntu lucid main" >> "/etc/apt/sources.list""
	#fi
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 34EF4A35
	sudo add-apt-repository ppa:rabbitvcs/ppa

	# update all sources ...
	sudo apt-get -y update
	return 0
}

add_apt_packages_source

# for common 
sudo apt-get -y install gcc build-essential 
#sudo apt-get -y install manpages-dev libc6-dev gcc-4.1-doc  cpp-4.1-doc manpages libstdc++6-4.2-dev autoconf automake binutils-doc cpp-doc gcc-doc glibc-doc libstdc++6-4.2-doc stl-manual flex bison
sudo apt-get -y install libc6-dev-i386

# for android .

# my develop packages ...
sudo apt-get -y install meld subversion vim vim-gnome 
sudo apt-get -y install qemu
sudo apt-get -y install uex ncdu tree
sudo apt-get -y install libvte-dev geany
sudo apt-get -y install cscope ctags

# hex editor gui .
sudo apt-get -y install bless
# hex editor and compare .
sudo apt-get -y install lfhex


# install for subversion server ...
sudo apt-get -y install apache2 apache2-doc libapache2-svn subversion
sudo svnadmin create /var/local/svnroot
sudo chown -R www-data:www-data /var/local/svnroot

# svn client bug fix : for connot connect to svn server issue .
sudo apt-get -y -f install
sudo apt-get -y install libneon27 libneon27-gnutls

# install for ltib ...
sudo apt-get -y install zlib1g-dev libncurses-dev m4 bison rpm ccache flex
# to solve build fail while prepare freetype package with command "./ltib -c"
sudo apt-get -y install libfreetype6-dev
# to solve build fail while prepare glib2 package with command "./ltib -c"
sudo apt-get -y install gettext libglib2.0-dev

# install texinfo for buildroot .
sudo apt-get -y install texinfo 

# install new mercurial for tortoisehg .
sudo apt-get install -y mercurial
# install tortoisehg .
sudo apt-get install -y tortoisehg tortoisehg-nautilus


# install rabbitvcs
sudo apt-get install -y python-nautilus python-configobj python-gtk2 python-glade2 python-svn python-dbus subversion meld
sudo apt-get install -y rabbitvcs-cli  rabbitvcs-core rabbitvcs-gedit rabbitvcs-nautilus rabbitvcs-thunar thunarx-python

