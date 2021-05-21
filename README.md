# pacman-for-termux

## Note:
This pacman is not fully wall-mounted, so there may be bugs.  If you find a bug, write in the issues.  

## A warning:
Do not use `--overwrite` when installing packages as there is a chance of breaking the termux system.

## Commands for installing pacman.
```
pkg update -y && pkg upgrade -y
pkg install git -y
git clone https://github.com/Maxython/pacman-for-termux
cd pacman-for-termux
./install.sh
```
