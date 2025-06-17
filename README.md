# nix-conf

Nix configuration

Add git to the nix packages, then add the following to the bottom of the nix configuration:

```
nix.settings.experimental-features = [ "nix-command" "flakes" ];
nix.settings.download-buffer-size = 268435456;
```

Add home manager:

```
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

Save the file, then run the following:

```
sudo nixos-rebuild switch
git clone https://github.com/theepicviolin/nix-conf.git ~/.dotfiles
sudo nixos-rebuild switch --flake ~/.dotfiles
```
