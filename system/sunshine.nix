{
  #config,
  #lib,
  pkgs,
  settings,
  ...
}:
let
  run-steam-url = pkgs.writeShellApplication {
    name = "steam-run-url";
    text = ''
      echo "$1" > "/run/user/$(id --user)/steam-run-url.fifo"
    '';
    runtimeInputs = [
      pkgs.coreutils # For `id` command
    ];
  };
in
{
  systemd.user.services.steam-run-url-service = {
    enable = true;
    description = "Listen and starts steam games by id";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig.Restart = "on-failure";
    script = toString (
      pkgs.writers.writePython3 "steam-run-url-service" { } ''
        import os
        from pathlib import Path
        import subprocess

        pipe_path = Path(f'/run/user/{os.getuid()}/steam-run-url.fifo')
        try:
            pipe_path.parent.mkdir(parents=True, exist_ok=True)
            pipe_path.unlink(missing_ok=True)
            os.mkfifo(pipe_path, 0o600)
            while True:
                with pipe_path.open(encoding='utf-8') as pipe:
                    subprocess.Popen(['steam', pipe.read().strip()])
        finally:
            pipe_path.unlink(missing_ok=True)
      ''
    );
    path = [
      pkgs.steam
    ];
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    settings = {
      output_name = 1;
      sunshine_name = settings.hostnamedisplay;
    };
    applications = {
      env.PATH = "/run/current-system/sw/bin";
      apps = [
        {
          name = "Desktop";
          auto-detach = true;
          exclude-global-prep-cmd = false;
          exit-timeout = 5;
          image-path = "desktop.png";
          prep-cmd = [
            {
              do = "gnome-monitor-config set -Lp -M DP-1";
              undo = "gnome-monitor-config set -Lp -M DP-1 -L -M HDMI-1 -x 1920 -L -M DP-2 -x 3840";
            }
          ];
          wait-all = true;
        }
        {
          "name" = "Steam Big Picture";
          "auto-detach" = true;
          "detached" = [
            "steam-run-url steam://open/bigpicture"
          ];
          "exclude-global-prep-cmd" = false;
          "exit-timeout" = 5;
          "image-path" = "steam.png";
          "prep-cmd" = [
            {
              "do" = "";
              "undo" = "steam-run-url steam://close/bigpicture";
            }
            {
              "do" = "gnome-monitor-config set -Lp -M DP-3 -m 3840x2160@60.000 -s 2";
              "undo" = "gnome-monitor-config set -Lp -M DP-1 -L -M HDMI-1 -x 1920 -L -M DP-2 -x 3840";
            }
          ];
          "wait-all" = true;
        }
      ];
    };
  };

  environment.systemPackages = [
    run-steam-url
    pkgs.gnome-monitor-config
  ];
}
