{
  config,
  lib,
  pkgs,
  #settings,
  ...
}:
{
  options = {
    vscodium.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = with config.vscodium; {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default = {
        extensions = with pkgs.nix-vscode-extensions.open-vsx; [
          atlassian.atlascode
          synedra.auto-run-command
          dbaeumer.vscode-eslint
          pkgs.nix-vscode-extensions.vscode-marketplace.github.copilot
          eamodio.gitlens
          golang.go
          haskell.haskell
          justusadam.language-haskell
          jnoortheen.nix-ide
          jeanp413.open-remote-ssh
          esbenp.prettier-vscode
          mads-hartmann.bash-ide-vscode
          ms-python.python
          ms-python.pylint
          ms-python.black-formatter
          ms-python.debugpy
          msjsdiag.vscode-react-native
          coolbear.systemd-unit-file
          redhat.vscode-yaml
        ];
        userSettings = lib.importJSON ./settings.json;
      };
    };
  };
}
