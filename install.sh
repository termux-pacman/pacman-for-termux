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
  conf=$PREFIX/etc/pacman.conf
  sed -i 's/#this//' $conf
  sed -i 's+RootDir     = /data/data/com.termux/files/usr/+RootDir     = /data/data/com.termux/files/+' $conf
  un="`uname -m`"
  if [[ $un == "armv6l" ]]; then
    sed -i 's/Architecture = auto/Architecture = armv6h/' $conf
  elif [[ $un == "armv7l" ]]; then
    sed -i 's/Architecture = auto/Architecture = armv7h/' $conf
  fi

  info 'Run pacman.'
  pacman -Syu

  info 'Setting up termux.'
  for i in bin lib
  do
    if [[ ! -d /data/data/com.termux/files/$i ]]; then
      ln -s $PREFIX/$i /data/data/com.termux/files/$i
    fi
  done
  chroot=$PREFIX/bin/termux-chroot
  if [[ -z "`grep 'ARGS="$ARGS -b /sys:/sys"' $chroot`" ]]; then
    sed -i '35a\ARGS="$ARGS -b /sys:/sys"' $chroot
  fi
  if [[ -z "`grep 'ARGS="$ARGS --link2symlink"' $chroot`" ]]; then
    sed -i '35a\ARGS="$ARGS --link2symlink"' $chroot
  fi
  if [[ -f $PREFIX/bin/login ]]; then
    rm $PREFIX/bin/login
  fi
  etc=$PREFIX/etc
  rm $etc/profile
  wget -P $etc --inet4-only https://raw.githubusercontent.com/Maxython/arch-packages-for-termux/main/profile/usr/etc/profile

  info 'Removing deb packages.'
  apt-get purge clang python -y
  apt autoremove -y
  pkg install libarchive -y
  
  info 'Reload termux.'
  sleep 3
  kill -9 $PPID
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
  pacman-key --init
  pacman -S filesystem archlinuxarm-keyring --noconfirm --color=always #archlinux-keyring
  pacman-key --populate
}

if [[ "$1" == "help" ]]; then
  info 'Help'
  commet './install.sh [com1] [com2]'
  commet 'Installer script for pacman on termux.'
  commet 'The latest available version of pacman is 5.2.2 .'
  commet 'Commands with [auto] highlighted will be executed automatically if nothing is specified.'
  commet 'When running a specific command, only that command will be executed.'
  commet 'Commands:'
  commet '  upd[auto] - installing and updating packages.'
  commet '  ins[auto] - installing pacman.'
  commet '    conf[auto] - run the configure script.'
  commet '    make[auto] - run make.'
  commet '    ins[auto] - run make install'
  commet '  set[auto] - setting up pacman.'
  commet '  set2 - second part of pacman setup (only run after termux reboot).'
  commet '  test - сompiling pacman for a test.'
elif [[ "$1" == "test" ]]; then
  install_pacman "conf"
  install_pacman "make"
elif [[ "$1" == "set2" ]]; then
  settings2_pacman $2
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
