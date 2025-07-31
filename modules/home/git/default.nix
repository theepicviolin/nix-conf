{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.git;
in
{
  options.ar.git = {
    enable = mkEnableOption "Enable git and set default config values";
    name = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.name;
      userEmail = cfg.email;
      aliases = {
        s = "status";
      };
      extraConfig = {
        credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
        init = {
          defaultBranch = "main";
        };
        push = {
          autoSetupRemote = true;
        };
        pull = {
          rebase = true;
        };
      };
    };

  };
}
