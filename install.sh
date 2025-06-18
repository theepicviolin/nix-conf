#!/bin/bash

# add home manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# rebuild
sudo nixos-rebuild switch
git clone https://github.com/theepicviolin/nix-conf.git ~/.dotfiles
sudo cp /etc/nixos/hardware-configuration.nix ~/.dotfiles
cd ~/.dotfiles
git add ~/.dotfiles/hardware-configuration.nix
sudo nixos-rebuild switch --flake ~/.dotfiles
home-manager switch --flake ~/.dotfiles

#1password -w >/dev/null 2>&1

# start librewolf and kill it after a second, to generate the profile
librewolf & 
PID=$!
sleep 1
kill $PID 2>/dev/null
wait $$PID 2>/dev/null

# get librewolf settings
PROFILE_DIR="$HOME/.librewolf"
LWTMP_DIR="$HOME/.lwtmp"
git clone https://github.com/theepicviolin/LibreWolfCustomization.git $LWTMP_DIR
DEFAULT_PROFILE=$(find "$PROFILE_DIR" -maxdepth 1 -type d -name "*.default" -printf "%f\n")
cp "$LWTMP_DIR/". "$PROFILE_DIR/$DEFAULT_PROFILE" -a
rm "$LWTMP_DIR" -r -f
