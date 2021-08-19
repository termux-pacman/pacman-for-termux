#!/system/bin/sh
# -----------------------------
# Script for installing pacman.
# by: Maxython
# https://github.com/Maxython/pacman-for-termux
# -----------------------------

info(){
echo -e "\033[1;36m\n# $1\033[0m"
}

commet(){
echo -e "\033[0;32m# $1\033[0m"
}

error(){
echo -e "\033[1;31m# $1\033[0m"
}

install_packages(){
  info 'System and package updates.'
  apt update -y
  apt upgrade -y

  info 'Installing packages.'
  apt install build-essential asciidoc gpgme nettle wget curl proot bsdtar bash-completion ninja -y
  pip install meson
}

install_pacman(){
  dir=pacman-${type}
  if [[ ! -d $dir ]]; then
    error 'Not found: pacman.'
    exit 2
  fi
  cd $dir
  case $1 in
    "")
      info 'Installing pacman.'
      meson build
      sed -i 's/cc $ARGS -o $out $in $LINK_ARGS/cc $ARGS -o $out $in $LINK_ARGS -landroid-glob/' build/build.ninja
      ninja -C build install
    ;;

    "mes")
      info 'Running meson build.'
      meson build
    ;;

    "com")
      info 'Compiling pacman.'
      sed -i 's/cc $ARGS -o $out $in $LINK_ARGS/cc $ARGS -o $out $in $LINK_ARGS -landroid-glob/' build/build.ninja
      ninja -C build
    ;;

    "ins")
      info 'Installing pacman.'
      ninja -C build install
    ;;

    *)
      error "The command '$1' was not found.  For more information, enter './install.sh help'."
      exit 1
    ;;
  esac

  cd ..
}

settings_pacman(){
  if [[ "$type" == "arch" ]]; then
    info 'Pacman settings.'
    wget --inet4-only http://mirror.archlinuxarm.org/aarch64/core/pacman-mirrorlist-20210307-1-any.pkg.tar.xz
    pacman -U pacman-mirrorlist-20210307-1-any.pkg.tar.xz --noconfirm
    rm pacman-mirrorlist-20210307-1-any.pkg.tar.xz
    conf=$PREFIX/etc/pacman.conf
    sed -i 's/#this//' $conf
    sed -i 's+RootDir     = /data/data/com.termux/files/usr/+RootDir     = /data/data/com.termux/files/+' $conf
    un="`uname -m`"
    if [[ $un == "armv7l" ]]; then
      sed -i 's/Architecture = auto/Architecture = armv7h/' $conf
    fi

    info 'Run pacman.'
    pacman -Syu

    info 'Setting up termux.'
    bin=$PREFIX/bin
    for i in termux-chroot login
    do
      rm $bin/$i
      wget -P $bin --inet4-only https://raw.githubusercontent.com/Maxython/arch-packages-for-termux/main/termux-commands/usr/bin/$i
      chmod +x $bin/$i
    done
    sed -i 's/ARGS="$ARGS -0"/#ARGS="$ARGS -0"/' $bin/termux-chroot
    
    etc=$PREFIX/etc
    rm $etc/profile
    wget -P $etc --inet4-only https://raw.githubusercontent.com/Maxython/arch-packages-for-termux/main/profile/usr/etc/profile

    info 'Removing deb packages.'
    apt-get purge clang python ninja bash-completion bsdtar -y
    apt autoremove -y
    apt install libarchive -y

    mv $bin/bash $bin/bashTermux
    
    [[ -f ~/.termux/shell ]] && rm ~/.termux/shell

    info 'Reload termux.'
    sleep 2
    kill -9 $PPID
  fi
}

settings2_pacman(){
  if [[ "$type" == "arch" ]]; then
    info 'Start the second part of the setup.'
    pacman -Syu
    pacman-key --init
    pacman -S filesystem archlinuxarm-keyring --noconfirm --color=always --overwrite "*"  #archlinux-keyring
    pacman-key --populate
  else
    info "You have pacman termux type, nothing to configure."
  fi
}

set -e

clear

selec=$HOME/pacman-for-termux/selec.conf
if [[ ! -f $selec ]]; then
  info "Select the pacman view, they are configured for a specific environment and for a specific type of command installation.  The script will also set up the environment for a particular kind of pacman."
  PS3='Please enter your choice: '
  options=("Arch" "Termux" "Quit")
  select opt in "${options[@]}"
  do
    case $opt in
      "Arch")
        echo "type=arch" > $selec
        break
        ;;

      "Termux")
        echo "type=termux" > $selec
        break
        ;;

      "Quit")
        error "$selec file not found"
        exit 2
        ;;
      *) error "invalid option $REPLY";;
    esac
  done
fi
source $selec


case $1 in
  "")
    install_packages
    install_pacman $2
    settings_pacman
    ;;

  "help")
    info 'Help'
    commet './install.sh [com1] [com2]'
    commet 'Installer script for pacman on termux.'
    commet 'The latest available version of pacman is 6.0.0 .'
    commet 'Commands with [auto] highlighted will be executed automatically if nothing is specified.'
    commet 'When running a specific command, only that command will be executed.'
    commet 'If an error occurs during installation or pacman does not work correctly, write there:'
    commet 'https://github.com/Maxython/pacman-for-termux/issues'
    commet 'Commands:'
    commet '  upd[auto] - installing and updating packages.'
    commet '  ins[auto] - installing pacman.'
    commet '    mes[auto] - Running meson build.'
    commet '    com[auto] - Compiling pacman.'
    commet '    ins[auto] - Installing pacman.'
    commet '  set[auto] - setting up pacman.'
    commet '  set2 - second part of pacman setup (only run after termux reboot).'
    commet '  test - сompiling pacman for a test.'
    ;;

  "upd")
    install_packages
    ;;

  "ins")
    install_pacman $2
    ;;

  "set")
    settings_pacman
    ;;

  "set2")
    settings2_pacman
    ;;

  "test")
    info 'Compiling pacman for a test (testing it).'
    install_pacman mes
    install_pacman com
    ;;

  *)
    error "The command '$1' was not found.  For more information, enter './install.sh help'."
    exit 1
    ;;
esac


info 'Done.'
