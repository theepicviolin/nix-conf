{
  pkgs,
  lib,
  hostName,
  flake,
  inputs,
  ...
}:
with lib;
with flake.lib;
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ]
  ++ lib.attrsets.attrValues flake.nixosModules
  ++ lib.attrsets.attrValues flake.modules.common;

  home-manager.users = lib.mkForce { }; # use standalone home-manager

  nixpkgs.hostPlatform = "aarch64-linux";

  ar =
    let
      settings = {
        desktop-environment = "";
      };
    in
    {
      common = {
        enable = true;
        # graphicalBoot = true;
        # autoUpgrade = true;
        # autoGc = true;
      };
      _1password = enabled;
      # sunshine = {
      #   enable = true;
      #   displayname = "Numerical Nexus";
      # };
      # protonvpn = enabled;
      # virtualisation = enabled;
      # printer = enabled;
      # sound = enabled;
      gnome.enable = (settings.desktop-environment == "gnome");
      plasma.enable = (settings.desktop-environment == "plasma");
    };

  wsl.enable = true;
  wsl.defaultUser = "aditya";
  wsl.startMenuLaunchers = true;
  programs.nix-ld.enable = true;

  system.activationScripts = {
    # https://github.com/nix-community/NixOS-WSL/blob/main/modules/wsl-distro.nix#L165-L181
    # copy from home-manager as well
    copy-more-launchers = (
      stringAfter [ ] ''
        for x in applications icons; do
          echo "setting up /usr/share/''${x}..."
          targets=()
          if [[ -d "/home/aditya/.nix-profile/share/$x" ]]; then
            targets+=("/home/aditya/.nix-profile/share/$x/.")
          fi

          if (( ''${#targets[@]} != 0 )); then
            mkdir -p "/usr/share/$x"
            ${pkgs.rsync}/bin/rsync --archive --copy-dirlinks --recursive "''${targets[@]}" "/usr/share/$x"
          fi
        done
      ''
    );
  };

  environment.systemPackages = with pkgs; [
    openssl
    wget
  ];

  # users.users.aditya = {
  #   isNormalUser = true;
  #   linger = true;
  #   description = "Aditya Ramanathan";
  #   shell = pkgs.fish;
  #   extraGroups = [
  #     "networkmanager"
  #     "wheel"
  #   ];
  # };

  system.stateVersion = "25.11"; # Don't change this unless you know what you're doing!
}
