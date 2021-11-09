# pacman-for-termux

![repo size](https://img.shields.io/github/repo-size/Maxython/pacman-for-termux)
![tag](https://img.shields.io/github/v/tag/Maxython/pacman-for-termux)

Configured pacman to install packages on termux. There are two kinds of pacman, **arch** and **termux**.  The main difference between the two is the support for installing packages (**pacman-arch** installs arch packages and **pacman-termux** installs termux packages).

## A warning:
#### pacman-termux
There may be problems installing the package due to dependencies.  
```bash
# Installing packages without dependencies
pacman -Sdd *package_name*
```
The same problem can arise in `makepkg`.
```bash
# Compiling a package without dependency
# If you get an error due to missing packages, install them via apt
makepkg -d
pacman -Udd *package_file_name*
```

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
