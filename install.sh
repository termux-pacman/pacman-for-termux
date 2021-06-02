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

install_packages(){
  info 'System and package updates.'
  pkg update -y
  pkg upgrade -y

  info 'Installing packages.'
  pkg install build-essential asciidoc gpgme nettle wget curl proot -y
}

install_pacman(){
  info 'Installing pacman.'
  if [[ ! -d pacman ]]; then
    error 'Not found: pacman.'
    exit 2
  fi
  cd pacman
  if [[ -z $1 || "$1" == "conf" ]]; then
    commet 'Run the configure script.'
    ./configure --prefix=$PREFIX
  fi
  if [[ -z $1 || "$1" == "make" ]]; then
    commet 'Run make.'
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
  fi
  if [[ -z $1 || "$1" == "ins" ]]; then
    commet 'Run make install.'
    make install
  fi
  cd ..
}

settings_pacman(){
  info 'Pacman settings.'
  chmod 755 /data/data/com.termux/files/*
  chmod 755 $PREFIX/*
  wget --inet4-only http://mirror.archlinuxarm.org/aarch64/core/pacman-mirrorlist-20210307-1-any.pkg.tar.xz
  pacman -U pacman-mirrorlist-20210307-1-any.pkg.tar.xz --noconfirm
  rm pacman-mirrorlist-20210307-1-any.pkg.tar.xz
  sed -i 's/#this//' $PREFIX/etc/pacman.conf
  sed -i 's+RootDir     = /data/data/com.termux/files/usr/+RootDir     = /data/data/com.termux/files/+' $PREFIX/etc/pacman.conf
  if [[ "`uname -m`" == "armv7l" ]]; then
    sed -i 's/Architecture = auto/Architecture = armv7h/' $PREFIX/etc/pacman.conf
  fi

  info 'Run pacman.'
  pacman -Syu

  info 'Setting up termux.'
  ln -s $PREFIX/bin /data/data/com.termux/files/bin
  ln -s $PREFIX/lib /data/data/com.termux/files/lib
  file=$PREFIX/etc/profile
  if [[ -z "`grep termux-chroot $file`" ]]; then
    echo 'if [ -z "$TERMUX_CHROOT" ]; then' >> $file
    echo '  export TERMUX_CHROOT=1' >> $file
    echo '  exec termux-chroot' >> $file
    echo 'fi' >> $file
    echo 'unset LD_PRELOAD' >> $file
    commet 'The setup is ready.'
    info 'Reload termux.'
  else
    commet 'Everything is set up already.'
  fi
}

settings2_pacman(){
  info 'Start the second part of the setup.'
  if [[ ! -d /bin || ! -d /lib ]]; then
    error 'The /bin and /lib directory is not available.'
    exit 2
  fi
  pacman -Syu
  rm /bin
  rm /lib
  pacman -S filesystem archlinuxarm-keyring --noconfirm
  pacman-key --init
  pacman-key --populate archlinuxarm

  info 'Removing deb packages.'
  apt-get purge clang -y
  apt autoremove -y
  pkg install libarchive -y
}

if [[ "$1" == "help" ]]; then
  info 'Help'
  commet 'When running a specific command, only that command will be executed.'
  commet 'Commands:'
  commet '  upd - installing and updating packages.'
  commet '  ins - installing pacman.'
  commet '    conf - run the configure script.'
  commet '    make - run make.'
  commet '    ins - run make install'
  commet '  set - setting up pacman.'
  commet '  set2 - second part of pacman setup (only run after termux reboot).'
  commet '  test - сompiling pacman for a test.'
  echo
elif [[ "$1" == "test" ]]; then
  install_pacman "conf"
  install_pacman "make"
elif [[ "$1" == "set2" ]]; then
  settings2_pacman
else
  if [[ -z $1 || "$1" == "upd" ]]; then
    install_packages
  fi
  if [[ -z $1 || "$1" == "ins" ]]; then
    install_pacman $2
  fi
  if [[ -z $1 || "$1" == "set" ]]; then
    settings_pacman
  fi
fi

info 'Done.'
