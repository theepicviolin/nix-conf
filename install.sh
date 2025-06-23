#!/bin/bash

# add home manager
echo "##############################"
echo "# Installing Home Manager... #"
echo "##############################"
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
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
sudo cp /etc/nixos/configuration.nix ~/.dotfiles/configuration.nix.bak
sudo cp /etc/nixos/hardware-configuration.nix ~/.dotfiles
cd ~/.dotfiles
git add ~/.dotfiles/hardware-configuration.nix
chmod +x ~/.dotfiles/disable-gpp0.sh

echo "###########################################"
echo "# MAKE NECESSARY CHANGES TO CONFIGURATION #" 
echo "# (BOOT LOADER DEVICE, HOST NAME, ETC.)   #"
echo "# PRESS ENTER TO CONFIRM AND CONTINUE     #"
echo "###########################################"
read -p "Press Enter to continue..."

echo "##########################"
echo "# Full system rebuild... #"
echo "##########################"
sudo nixos-rebuild switch --flake ~/.dotfiles
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
echo "#############################################"
echo "# Full Home Manager rebuild finished        #"

# start librewolf and kill it after a second, to generate the profile
echo "# Starting LibreWolf to generate profile... #"
librewolf & 
PID=$!
sleep 1
kill $PID 2>/dev/null
wait $$PID 2>/dev/null

# get librewolf settings
echo "# Copying LibreWolf settings...             #"
echo "#############################################"
PROFILE_DIR="$HOME/.librewolf"
LWTMP_DIR="$HOME/.lwtmp"
git clone https://github.com/theepicviolin/LibreWolfCustomization.git $LWTMP_DIR
DEFAULT_PROFILE=$(find "$PROFILE_DIR" -maxdepth 1 -type d -name "*.default" -printf "%f\n")
cp "$LWTMP_DIR/". "$PROFILE_DIR/$DEFAULT_PROFILE" -a
rm "$LWTMP_DIR" -r -f
echo "############"
echo "# Finished #"
echo "############"
echo "Close this terminal and open a new one to start using your new NixOS system."
