#!/data/data/com.termux/files/usr/bin/bash
#Script for installing pacman.

info(){
echo -e "\033[1;36m\n# $1\033[0m"
}

commet(){
echo -e "\033[0;37m# $1\033[0m"
}

error(){
echo -e "\033[1;31m# $1\033[0m"
}

info 'System and package updates.'
pkg update -y
pkg upgrade -y

info 'Installing packages.'
pkg install build-essential asciidoc gpgme nettle wget curl -y

info 'Directory creation.'
for i in var/cache/ sbin usr
do
	dir="$PREFIX/$i"
	if [[ -d $dir ]]; then
		commet "Found: $dir"
	else
		mkdir $dir
		commet "Create: $dir"
	fi
done

info 'Installing pacman.'
if [[ ! -d pacman ]]; then
	error 'Not found: pacman.'
	exit 2
fi
cd pacman
./configure --prefix=$PREFIX
make
make install

info 'Pacman settings.'
wget http://mirror.archlinuxarm.org/aarch64/core/pacman-mirrorlist-20210307-1-any.pkg.tar.xz
pacman -U pacman-mirrorlist-20210307-1-any.pkg.tar.xz --noconfirm
rm pacman-mirrorlist-20210307-1-any.pkg.tar.xz
#wget http://mirror.archlinuxarm.org/armv6h/core/archlinuxarm-keyring-20140119-1-any.pkg.tar.xz
pacman -U archlinuxarm-keyring-20140119-1-termux.pkg.tar.xz --noconfirm
#rm archlinuxarm-keyring-20140119-1-any.pkg.tar.xz
sed -i 's/#this//' $PREFIX/etc/pacman.conf
pacman-key --init
pacman-key --populate archlinuxarm

info 'Done.'
