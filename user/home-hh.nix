{
  #config,
  pkgs,
  # pkgs-stable,
  lib,
  settings,
  inputs,
  ...
}:

{
  imports =
    with lib.lists;
    [
      ./shells/shells.nix
      ./syncthing/syncthing.nix
    ]
    ++ (optional (settings.desktop-environment == "gnome") ./desktop-environments/gnome.nix)
    ++ (optional (settings.desktop-environment == "plasma") ./desktop-environments/plasma.nix);

  options = {
    # Define options here, e.g.:
    # myOption = lib.mkOption {
    #   type = lib.types.str;
    #   default = "default value";
    #   description = "An example option.";
    # };
  };

  config =
    # let
    #   utils = {
    #     mutableDotfile =
    #       cfgDir: cfgFile: templateFile:
    #       lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #         if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
    #           mkdir -p "${settings.homedir}/${cfgDir}"
    #           cp "${settings.dotdir}/${templateFile}" "${settings.homedir}/${cfgDir}/${cfgFile}"
    #         fi
    #       '';
    #     mutableDottext =
    #       cfgDir: cfgFile: text:
    #       lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #         if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
    #           mkdir -p "${settings.homedir}/${cfgDir}"
    #           echo "${text}" > "${settings.homedir}/${cfgDir}/${cfgFile}"
    #         fi
    #       '';
    #     replaceFile =
    #       cfgDir: cfgFile: file:
    #       lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #         if [ -f "${settings.homedir}/${cfgDir}/${cfgFile}" ]; then
    #           if [ ! -f "${settings.homedir}/${cfgDir}/${cfgFile}.bak" ]; then
    #             mv "${settings.homedir}/${cfgDir}/${cfgFile}" "${settings.homedir}/${cfgDir}/${cfgFile}.bak"
    #           fi
    #           cp "${settings.dotdir}/${file}" "${settings.homedir}/${cfgDir}/${cfgFile}"
    #           chmod 755 "${settings.homedir}/${cfgDir}/${cfgFile}"
    #         fi
    #       '';

    #     mimeToAppMap =
    #       appMimeMap:
    #       (builtins.foldl' (
    #         acc: app:
    #         acc
    #         // builtins.listToAttrs (
    #           map (mime: {
    #             name = mime;
    #             value = [ app ];
    #           }) appMimeMap.${app}
    #         )
    #       ) { } (builtins.attrNames appMimeMap));
    #   };
    # in
    {
      home.username = settings.username;
      home.homeDirectory = settings.homedir;

      home.stateVersion = "25.05"; # Don't change this unless you know what you're doing!

      nixpkgs.config.allowUnfree = true;

      home.sessionVariables = {
        # EDITOR = "emacs";
      };

      programs.git = {
        enable = true;
        userName = settings.fullname;
        userEmail = settings.email;
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

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
}
