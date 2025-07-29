#!/bin/bash

# add home manager
echo "##############################"
echo "# Installing Home Manager... #"
echo "##############################"
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# rebuild
echo "############################"
echo "# Cloning nix conf ...     #"
echo "############################"
git clone https://github.com/theepicviolin/nix-conf.git ~/.dotfiles
# sudo cp /etc/nixos/configuration.nix ~/.dotfiles/configuration.nix.bak
mv ~/.dotfiles/system/hardware-configuration-hh.nix ~/.dotfiles/system/hardware-configuration-hh.nix.bak
sudo cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/system/hardware-configuration-hh.nix
cd ~/.dotfiles
git add ~/.dotfiles/system/hardware-configuration-hh.nix

echo "###########################################"
echo "# MAKE NECESSARY CHANGES TO CONFIGURATION #" 
echo "# (BOOT LOADER DEVICE, HOST NAME, ETC.)   #"
echo "# PRESS ENTER TO CONFIRM AND CONTINUE     #"
echo "###########################################"
read -p "Press Enter to continue..."

echo "##########################"
echo "# Full system rebuild... #"
echo "##########################"
sudo nixos-rebuild switch --flake ~/.dotfiles#harmony-host
echo "################################"
echo "# Full system rebuild finished #"
echo "################################"

echo "################################"
echo "# Full Home Manager rebuild... #"
echo "################################"
home-manager switch --flake ~/.dotfiles
echo "######################################"
echo "# Full Home Manager rebuild finished #"
echo "#             Finished               #"
echo "######################################"
echo "Close this terminal and open a new one to start using your new NixOS system."
