#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"
rootpassword=password
username=user
userpassword=password

mkdir distro/
cd distro/

builddate=$(wget -O - http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/ | sed -nr "s/.*href=\"stage3-amd64-([0-9].*).tar.xz\">.*/\1/p")
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-$builddate.tar.xz
tar pxf stage3*
rm -f stage3*

cp /etc/resolv.conf etc/
# mount -t proc none proc
# mount --rbind /dev dev
# mount --rbind /sys sys
cd ..
tar -czf distro.tar.gz distro



