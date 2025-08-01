{
  config,
  lib,
  # pkgs,
  ...
}:
with lib;
let
  cfg = config.ar.shells;
  shellAliases = {
    md = "mkdir";
    "." = "start .";
    ".." = "cd ..";
    "..." = "cd ../..";
    rebuildn = "sudo nixos-rebuild switch --flake ${cfg.dotdir}";
    rebuildh = "home-manager switch --flake ${cfg.dotdir}";
    rebuild = "rebuildn; rebuildh";
    rn = "rebuildn";
    rh = "rebuildh";
    r = "rebuildn && rebuildh";
    lg = "nixos-rebuild list-generations";
    start = "xdg-open";
  };

in
{
  options.ar.shells = {
    enable = mkEnableOption "Enable bash and fish shell configurations";
    dotdir = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
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
