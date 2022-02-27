# pacman-for-termux

![repo size](https://img.shields.io/github/repo-size/Maxython/pacman-for-termux)
![tag](https://img.shields.io/github/v/tag/Maxython/pacman-for-termux)

Configured pacman to install packages on termux. There are two kinds of pacman, **arch** and **termux**.  The main difference between the two is the support for installing packages (**pacman-arch** installs arch packages and **pacman-termux** installs termux packages). All termux services for pacman are located [here](https://github.com/Maxython/pacman-update-db).

## A warning:
Comparison with the new and with the old, here the problem of dependencies is solved, but not all packages are currently on the new service.  If you notice a package is missing in a new service, please post an issue [here](https://github.com/Maxython/termux-packages-pacman).

## Installing pacman via pkg.
```bash
pkg upd -y
pkg ins pacman -y
```

## Compiling and installing pacman.
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
