# nix-conf

Nix configuration

Edit the nix configuration file with:

```
sudo nano /etc/nixos/configuration.nix
```

Add git to the nix packages, then add the following to the bottom of the nix configuration file:

```
nix.settings.experimental-features = [ "nix-command" "flakes" ];
nix.settings.download-buffer-size = 268435456;
```

Save the file, then run the following:

```
source <(curl -s https://raw.githubusercontent.com/theepicviolin/nix-conf/refs/heads/main/install.sh)
```

## Misc setup steps that I can't make into a script :(

### LibreWolf

Open LibreWolf and enable all the extensions. Go to Userchrome's settings and enable Styles 2 and 3 and enable "Allow multiple styles to be active together"

Log into Firefox sync and in the LibreWolf Sidebery settings, go down to Sync and "View synced data" and import styles and settings. Optionally enable "Save settings to sync storage" and "Save styles to sync storage"
