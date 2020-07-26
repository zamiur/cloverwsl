#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"
rootpassword=password
username=$USER
userpassword=password

mkdir distro/
cd distro/

builddate=$(wget -O - http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/ | sed -nr "s/.*href=\"stage3-amd64-([0-9].*).tar.xz\">.*/\1/p")
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-$builddate.tar.xz
tar pxf stage3*
rm -f stage3*

cp /etc/resolv.conf etc/
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat <<HEREDOC | chroot .
mkdir /var/db/repos/gentoo
emerge-webrsync
eselect profile set "default/linux/amd64/17.1/hardened"
PORTAGE_BINHOST="https://cloveros.ga" emerge -G aria2
while ! gpg --list-keys "CloverOS GNU/Linux (Package signing)"; do gpg --keyserver hkp://pool.sks-keyservers.net --recv-key "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"; done
echo '
CFLAGS="-O3 -march=native -mfpmath=both -pipe -fgraphite-identity -floop-nest-optimize -funroll-loops -fipa-pta -ftracer -malign-data=cacheline -Wl,--hash-style=gnu"
CXXFLAGS="\${CFLAGS}"
CPU_FLAGS_X86="mmx mmxext sse sse2 ssse3 sse3"
ACCEPT_LICENSE="*"
MAKEOPTS="-j8"
PORTAGE_NICENESS=19
PORTAGE_BINHOST="https://cloveros.ga"
EMERGE_DEFAULT_OPTS="--jobs=4 --keep-going=y --autounmask-write=y -G"
ACCEPT_KEYWORDS="**"
binhost_mirrors="\$PORTAGE_BINHOST,https://useast.cloveros.ga,https://uswest.cloveros.ga,https://ca.cloveros.ga,https://fr.cloveros.ga,https://nl.cloveros.ga,https://uk.cloveros.ga,https://au.cloveros.ga,https://sg.cloveros.ga,https://jp.cloveros.ga,https://mirrors.nju.edu.cn/cloveros,https://cernet.mirrors.ustc.edu.cn/cloveros,"
FETCHCOMMAND_HTTPS="sh -c \"aria2c -x2 -s99 -j99 -k1M -d \"\\\${DISTDIR}\" -o \"\\\${FILE}\" \\\\\\\$(sed -e \"s#,#\\\${DISTDIR}/\\\${FILE}\"\ \"#g\" -e \"s#\$PKGDIR##g\" -e \"s#.partial##g\" <<< \$binhost_mirrors) & aria2c --allow-overwrite -d \"\\\${DISTDIR}\" -o \"\\\${FILE}.asc\" \\\\\\\$(sed -e \"s#,#/s/signatures/\\\${DISTDIR}/\\\${FILE}.asc\"\ \"#g\" -e \"s#\$PKGDIR##g\" -e \"s#.partial##g\" <<< \$binhost_mirrors) && wait && gpg --verify \"\\\${DISTDIR}/\\\${FILE}.asc\" \"\\\${DISTDIR}/\\\${FILE}\" && rm \"\\\${DISTDIR}/\\\${FILE}.asc\"\""' >> /etc/portage/make.conf

FETCHCOMMAND_HTTPS="wget -O \"\\\${DISTDIR}/\\\${FILE}\" \"\\\${URI}\"" emerge -1 gcc glibc acct-group/input acct-group/kvm acct-group/render sys-libs/pam virtual/libcrypt python:3.6 python:3.7 curl wget iputils openssh python:2.7

#emerge gentoo-sources genkernel
#wget https://raw.githubusercontent.com/damentz/liquorix-package/master/linux-liquorix/debian/config/kernelarch-x86/config-arch-64
#genkernel --kernel-config=config-arch-64 all

emerge grub dhcpcd
rc-update add dhcpcd default

echo "root:$rootpassword" | chpasswd
useradd $username
echo "$username:$userpassword" | chpasswd
gpasswd -a $username wheel

PORTAGE_BINHOST="https://cloveros.ga/s/nodbus" FETCHCOMMAND_HTTPS="wget -O \"\\\${DISTDIR}/\\\${FILE}\" \"\\\${URI}\"" emerge -1O glib wpa_supplicant gpgme spacefm linux-firmware mesa
rm -Rf /var/cache/binpkgs/*
emerge --noreplace wpa_supplicant spacefm linux-firmware
emerge -eDv --exclude "glib wpa_supplicant gpgme spacefm linux-firmware mesa" @world xorg-server fvwm rxvt-unicode nitrogen compton sudo porthole rtorrent weechat alsa-utils zsh zsh-completions gentoo-zsh-completions liberation-fonts hack vlgothic scrot xbindkeys xinput arandr slock xarchiver p7zip games-envd gparted squashfs-tools os-prober exfat-nofuse sshfs curlftpfs geeqie alsamixergui
emerge --depclean
emerge -1O mesa
echo "frozen-files=\"/etc/sudoers\"" >> /etc/dispatch-conf.conf
sed -i "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
sed -Ei "s@c([2-6]):2345:respawn:/sbin/agetty 38400 tty@#\0@" /etc/inittab
sed -i "s@c1:12345:respawn:/sbin/agetty 38400 tty1 linux@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@" /etc/inittab
echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel\nupdate_config=1" > /etc/wpa_supplicant/wpa_supplicant.conf
rc-update add alsasound
eselect fontconfig enable 52-infinality.conf
eselect infinality set infinality
eselect lcdfilter set infinality
cp /usr/share/zoneinfo/UTC /etc/localtime
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8
usermod -aG audio,video,games,input $username
cd /home/$username/
rm .bash_profile
wget $gitprefix/home/user/{.bash_profile,.zprofile,.zshrc,.fvwm2rc,.Xdefaults,wallpaper.png,wallpaper43.png,wallpaper1610.png,.xbindkeysrc,screenfetch-dev,cloveros_settings.sh,stats.sh,rotate_screen.sh,.emacs,.rtorrent.rc}
chmod +x screenfetch-dev cloveros_settings.sh stats.sh rotate_screen.sh
mkdir -p .emacs.d/backups/ .emacs.d/autosaves/ Downloads/ .rtorrent/ .mpv/ .config/spacefm/ .config/nitrogen/ .config/nomacs/ Desktop/
sed -i "s@/home/user/@/home/$username/@" .rtorrent.rc
wget $gitprefix/home/user/.mpv/config -P .mpv/
wget $gitprefix/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen/
sed -i "s@/home/user/@/home/$username/@" .config/nitrogen/nitrogen.cfg
wget $gitprefix/home/user/.config/nomacs/Image\ Lounge.conf -P .config/nomacs/
mkdir -p .mozilla/firefox/default/
echo -e "[Profile0]\nName=default\nIsRelative=1\nPath=default\nDefault=1" > .mozilla/firefox/profiles.ini
echo -e "[11457493C5A56847]\nDefault=default" > .mozilla/firefox/installs.ini
wget -O - https://spyware.neocities.org/guides/firefox.html | sed '/user_pref/,\$!d; s/<br>//; /devtools.webide.autoinstallADBHelper/q' > .mozilla/firefox/default/user.js
echo 'user_pref("pdfjs.disabled", false);' >> .mozilla/firefox/default/user.js
wget $gitprefix/home/user/.config/spacefm/session -P .config/spacefm/
sed -i "s@/home/user/@/home/$username/@" .config/spacefm/session
wget $gitprefix/home/user/.config/mimeapps.list -P .config/
echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Home\nIcon=user-home\nExec=spacefm ~/" > Desktop/home.desktop
echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Applications\nIcon=folder\nExec=spacefm /usr/share/applications/" > Desktop/applications.desktop
cp /usr/share/applications/{porthole.desktop,xarchiver.desktop} Desktop/
echo -e "~rows=0\n1=home.desktop\n2=applications.desktop\n3=porthole.desktop\n4=xarchiver.desktop" > .config/spacefm/desktop0
chown -R $username /home/$username/

wget $gitprefix/livecd_install.sh -P /home/$username/
chmod +x /home/$username/livecd_install.sh
sed -i "s@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@c1:12345:respawn:/sbin/agetty -a $username --noclear 38400 tty1 linux@" /etc/inittab
sed -i "s/^/#/" /home/$username/.bash_profile
echo -e 'if [ -z "\$DISPLAY" ] && [ -z "\$SSH_CLIENT" ] && ! pgrep X > /dev/null; then
X &
export DISPLAY=:0
fvwm &
while sleep 0.2; do if [ -d /proc/\$! ]; then ((i++)); [ "\$i" -gt 6 ] && break; else i=0; fvwm & fi; done
urxvtd -o -f
urxvtc -geometry 80x24+120+100 -e sudo ./livecd_install.sh
rc-config start wpa_supplicant &> /dev/null &
nitrogen --set-zoom wallpaper.png &
spacefm --desktop &
urxvtc -geometry 1000x1+0+0 -fn 6x13 -letsp 0 -sl 0 -e ~/stats.sh
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1 & xinput list --name-only | sed "/Virtual core pointer/,/Virtual core keyboard/"\!"d;//d" | xargs -I{} xinput set-prop pointer:{} "libinput Accel Profile Enabled" 0 1 &> /dev/null &
fi' >> /home/$username/.bash_profile

sed -i "s/nomacs/geeqie/g" .fvwm2rc .config/mimeapps.list
sed -i "s/qasmixer/alsamixergui/" .fvwm2rc
mkdir .config/geeqie/
wget $gitprefix/home/user/.config/geeqie/geeqierc.xml -P .config/geeqie/
chown -R $username /home/$username/
rm -Rf /var/db/repos/*

rm -Rf /var/cache/binpkgs/* /var/cache/edb/binhost/* /etc/resolv.conf /etc/portage/package.use/
tar -czf distro.tar.gz /
exit
HEREDOC


