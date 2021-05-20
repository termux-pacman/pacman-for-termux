#!/data/data/com.termux/files/usr/bin/bash
#Script for installing pacman.

info(){
echo -e "\033[1;36m\n# $1\033[0m"
}

commet(){
echo -e "\033[0;32m# $1\033[0m"
}

error(){
echo -e "\033[1;31m# $1\033[0m"
}

set -e

info 'System and package updates.'
pkg update -y
pkg upgrade -y

info 'Installing packages.'
pkg install build-essential asciidoc gpgme nettle wget curl -y

info 'Directory creation.'
dir=$PREFIX/var/cache/
if [[ -d $dir ]]; then
        commet "Found: $dir"
else
        mkdir $dir
        commet "Create: $dir"
fi

info 'Installing pacman.'
if [[ ! -d pacman ]]; then
        error 'Not found: pacman.'
        exit 2
fi
cd pacman
./configure --prefix=$PREFIX
set +e
while :
do
        make
        if (( "$?" == "0" )); then
                break
        else
                commet 'Error correction.'
                if [[ -z "`grep '$(AM_V_CCLD)$(LINK) $(pacman_OBJECTS) $(pacman_LDADD) $(LIBS) -landroid-glob' src/pacman/Makefile`" ]]; then
                        sed -i 's/$(AM_V_CCLD)$(LINK) $(pacman_OBJECTS) $(pacman_LDADD) $(LIBS)/$(AM_V_CCLD)$(LINK) $(pacman_OBJECTS) $(pacman_LDADD) $(LIBS) -landroid-glob/' src/pacman/Makefile
                fi
                if [[ -z "`grep '$(AM_V_CCLD)$(LINK) $(pacman_conf_OBJECTS) $(pacman_conf_LDADD) $(LIBS) -landroid-glob' src/pacman/Makefile`" ]]; then
                        sed -i 's/$(AM_V_CCLD)$(LINK) $(pacman_conf_OBJECTS) $(pacman_conf_LDADD) $(LIBS)/$(AM_V_CCLD)$(LINK) $(pacman_conf_OBJECTS) $(pacman_conf_LDADD) $(LIBS) -landroid-glob/' src/pacman/Makefile
                fi
        fi
done
set -e
make install
cd ..

info 'Pacman settings.'
wget http://mirror.archlinuxarm.org/aarch64/core/pacman-mirrorlist-20210307-1-any.pkg.tar.xz
pacman -U pacman-mirrorlist-20210307-1-any.pkg.tar.xz --noconfirm
rm pacman-mirrorlist-20210307-1-any.pkg.tar.xz
wget http://mirror.archlinuxarm.org/armv6h/core/archlinuxarm-keyring-20140119-1-any.pkg.tar.xz
pacman -U archlinuxarm-keyring-20140119-1-any.pkg.tar.xz --noconfirm
rm archlinuxarm-keyring-20140119-1-any.pkg.tar.xz
sed -i 's/#this//' $PREFIX/etc/pacman.conf
sed -i 's+RootDir     = /data/data/com.termux/files/usr/+RootDir     = /data/data/com.termux/files/+' $PREFIX/etc/pacman.conf
pacman-key --init
pacman-key --populate archlinuxarm

info 'Run pacman.'
pacman -Syu

#rm $PREFIX/etc/bindresvport.blacklist
#rm $PREFIX/etc/profile.d/gawk.sh
#dir=$PREFIX/lib
#for i in $(ls $dir)
#do
#       if [[ -d $dir/$i ]]; then
#               rm -fr $dir/$i
#       fi
#done

info 'Done.'
