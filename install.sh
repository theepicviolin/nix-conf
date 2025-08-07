#!/bin/bash

# add home manager
echo "##############################"
echo "# Installing Home Manager... #"
echo "##############################"
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# rebuild
echo "######################"
echo "# Initial rebuild... #"
echo "######################"
sudo nixos-rebuild switch
echo "############################"
echo "# Initial rebuild finished #"
echo "# Cloning nix conf ...     #"
echo "############################"
git clone https://github.com/theepicviolin/nix-conf.git ~/.dotfiles
mv ~/.dotfiles/hosts/$1/hardware-configuration.nix ~/.dotfiles/hosts/$1/hardware-configuration.nix.bak
sudo cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/hosts/$1
sudo cp /etc/nixos/disk-config.nix ~/.dotfiles/hosts/$1

echo "###########################################"
echo "# MAKE NECESSARY CHANGES TO CONFIGURATION #" 
echo "# (DISKO SETTINGS, HOST NAME, ETC.)       #"
echo "# PRESS ENTER TO CONFIRM AND CONTINUE     #"
echo "###########################################"
read -p "Press Enter to continue..."

echo "##########################"
echo "# Full system rebuild... #"
echo "##########################"
sudo nixos-rebuild switch --flake ~/.dotfiles#$1
echo "################################"
echo "# Full system rebuild finished #"
echo "# Starting 1Password...        #"
echo "################################"

# start 1password so the user can set it up while other stuff is installing 
nohup 1password -w >/dev/null 2>&1 &

echo "################################"
echo "# Full Home Manager rebuild... #"
echo "################################"
home-manager switch --flake ~/.dotfiles
echo "######################################"
echo "# Full Home Manager rebuild finished #"
echo "######################################"
echo "############"
echo "# Finished #"
echo "############"
echo "Close this terminal and open a new one to start using your new NixOS system."
