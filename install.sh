nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
sudo nixos-rebuild switch
git clone https://github.com/theepicviolin/nix-conf.git ~/.dotfiles
sudo cp /etc/nixos/hardware-configuration.nix ~/.dotfiles
cd ~/.dotfiles
git add ~/.dotfiles/hardware-configuration.nix
sudo nixos-rebuild switch --flake ~/.dotfiles
