# Information
**pacman-for-termux** is a project that allows you to use the pacman package manager and its tools (makepkg and repo-add) in termux. This repository used to be the beginning of pacman support development for termux, but now it plays the role of informing the user and the main work with pacman has been moved to the [termux/termux-packages](https://github.com/termux/termux-packages) repository.

# Installing pacman
Please note that in order to use pacman fully, you need to follow certain steps for this (how to do it is written [here](https://wiki.termux.com/wiki/Switching_package_manager)). But if you just want to get pacman with the tools, you can run the following command (although doing a **full install** of pacmam is also recommended here).
```bash
pkg upd -y
pkg ins pacman -y
```

# Useful links
 - [AUR in termux](https://wiki.termux.com/wiki/AUR)
 - [Official site org. Termux Pacman](https://termux-pacman.dev)
 - [Official service for pacman](https://service.termux-pacman.dev)
