#! /bin/bash
#! /bin/sh

sudo pacman -Scc
sudo pacman -Rns $(pacman -Qtdq)

###Svuotamento journal

sudo journalctl --vacuum-time=1d
sudo journalctl --vacuum-size=100M
