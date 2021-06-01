# pacman-for-termux

## Note:
At this point, pacman is not fully configured for termux, so there may be bugs.  

## A warning:
Do not use `--overwrite` when installing packages as there is a chance of breaking the termux system ([more details](https://github.com/termux/termux-packages/issues/6842#issuecomment-845887799)).

## Commands for installing pacman.
```
pkg update -y && pkg upgrade -y
pkg install git -y
git clone https://github.com/Maxython/pacman-for-termux
cd pacman-for-termux
./install.sh
```
After these commands, restart termux and run the following command.
```
cd pacman-for-termux
./install.sh set2
```
