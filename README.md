# pacman-for-termux

![repo size](https://img.shields.io/github/repo-size/Maxython/pacman-for-termux)
![tag](https://img.shields.io/github/v/tag/Maxython/pacman-for-termux)

Configured pacman to install packages on termux. There are two kinds of pacman, **arch** and **termux**.  The main difference between the two is the support for installing packages (**pacman-arch** installs arch packages and **pacman-termux** installs termux packages).  

Compiling packages and maintaining the pacman package repository service is provided by the [termux-pacman](https://github.com/termux-pacman) organization.

### Installing pacman via pkg (recommended way).
```bash
pkg upd -y
pkg ins pacman -y
```

### Compiling and installing pacman (not a recommended way as the source code in this repository is old).
```bash
pkg update -y
pkg install git -y
git clone https://github.com/Maxython/pacman-for-termux
cd pacman-for-termux
./install.sh
```
After these commands, restart termux and run the following command.
```bash
./pacman-for-termux/install.sh set2
```


## Note:
If you have installed pacman via apt, then you cannot use it fully, as there is a risk that you will break your system. If you want to use pacman as your default package manager (that is fully), then you will need to take other steps. How to do it is described [here](https://wiki.termux.com/wiki/Switching_package_manager).
