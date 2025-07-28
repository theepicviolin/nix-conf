{
  # config,
  lib,
  # pkgs,
  settings,
  ...
}:
let
  shellAliases = {
    md = "mkdir";
    "." = "start .";
    ".." = "cd ..";
    "..." = "cd ../..";
    rebuildn = "sudo nixos-rebuild switch --flake ${settings.dotdir}";
    rebuildh = "home-manager switch --flake ${settings.dotdir}";
    rebuild = "rebuildn; rebuildh";
    rn = "rebuildn";
    rh = "rebuildh";
    r = "rebuildn && rebuildh";
    lg = "nixos-rebuild list-generations";
    start = "xdg-open";
  };
in
{
  options = {
    shells.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = {
    programs.bash = {
      enable = true;
      inherit shellAliases;
      bashrcExtra = ''try() { nix-shell -p "$1" --run "$1"; }'';
    };

    programs.fish = {
      enable = true;
      inherit shellAliases;
      functions = {
        try = {
          body = ''nix-shell -p "$argv" --run "$argv"'';
        };
      };
    };
  };
}
