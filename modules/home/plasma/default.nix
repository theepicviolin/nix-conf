{
  config,
  lib,
  inputs,
  # pkgs,
  # settings,
  ...
}:
with lib;
with lib.ar;
let
  cfg = config.ar.plasma;
in
{
  imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

  options.ar.plasma = {
    enable = mkEnableOption "Configure custom KDE Plasma settings";
  };

  config = mkIf cfg.enable {
    programs.plasma = {
      enable = true;

      panels = [
        # Windows-like panel at the bottom
        {
          location = "bottom";
          widgets = [
            # We can configure the widgets by adding the name and config
            # attributes. For example to add the the kickoff widget and set the
            # icon to "nix-snowflake-white" use the below configuration. This will
            # add the "icon" key to the "General" group for the widget in
            # ~/.config/plasma-org.kde.plasma.desktop-appletsrc.
            # {
            #   name = "org.kde.plasma.kickoff";
            #   config = {
            #     General = {
            #       icon = "nix-snowflake-white";
            #       alphaSort = true;
            #     };
            #   };
            # }
            # Or you can configure the widgets by adding the widget-specific options for it.
            # See modules/widgets for supported widgets and options for these widgets.
            # For example:
            {
              kickoff = {
                sortAlphabetically = true;
                icon = "nix-snowflake-white";
              };
            }
            # Adding configuration to the widgets can also for example be used to
            # pin apps to the task-manager, which this example illustrates by
            # pinning dolphin and konsole to the task-manager by default with widget-specific options.
            {
              iconTasks = {
                launchers = [
                  "applications:librewolf.desktop"
                  "applications:org.kde.dolphin.desktop"
                  "applications:proton-mail.desktop"
                  "applications:obsidian.desktop"
                  "applications:discord.desktop"
                  "applications:codium.desktop"
                  "applications:org.freecad.FreeCAD.desktop"
                  "applications:OrcaSlicer.desktop"
                ];
              };
            }

            # If no configuration is needed, specifying only the name of the
            # widget will add them with the default configuration.
            #"org.kde.plasma.marginsseparator"
            # If you need configuration for your widget, instead of specifying the
            # the keys and values directly using the config attribute as shown
            # above, plasma-manager also provides some higher-level interfaces for
            # configuring the widgets. See modules/widgets for supported widgets
            # and options for these widgets. The widgets below shows two examples
            # of usage, one where we add a digital clock, setting 12h time and
            # first day of the week to Sunday and another adding a systray with
            # some modifications in which entries to show.
            {
              systemTray.items = {
                # We explicitly show bluetooth and battery
                shown = [
                  "org.kde.plasma.battery"
                  "org.kde.plasma.bluetooth"
                ];
                # And explicitly hide networkmanagement and volume
                hidden = [
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.volume"
                ];
              };
            }
            {
              digitalClock = {
                calendar.firstDayOfWeek = "sunday";
                time.format = "12h";
              };
            }

          ];
          #hiding = "autohide";
        }
      ];
    };

  };
}
