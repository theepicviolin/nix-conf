# nix-conf

Nix configuration

Add git to the nix packages, then add the following to the bottom of the nix configuration:

```
nix.settings.experimental-features = [ "nix-command" "flakes" ];
nix.settings.download-buffer-size = 268435456;
```

Save the file, then run the following:
`source <(curl -s https://raw.githubusercontent.com/theepicviolin/nix-conf/refs/heads/main/install.sh)`
