{ config
, pkgs
, theme
, ...
}:
let
  aerospacePlugin = pkgs.writeShellApplication rec {
    name = "aerospace_plugin";
    text = builtins.readFile ./plugins/aerospace.sh;
    derivationArgs.buildInputs = with pkgs; [
      aerospace
      sketchybar
    ];

    runtimeInputs = derivationArgs.buildInputs;
  };

  appNamePlugin = pkgs.writeShellApplication rec {
    name = "app_name_plugin";
    text = builtins.readFile ./plugins/app_name.sh;
    derivationArgs.buildInputs = [ pkgs.sketchybar ];
  };

  clockPlugin = pkgs.writeShellApplication rec {
    name = "clock_plugin";
    text = builtins.readFile ./plugins/clock.sh;
    derivationArgs.buildInputs = with pkgs; [
      aerospace
      sketchybar
    ];

    runtimeInputs = derivationArgs.buildInputs;
  };

  batteryPlugin = pkgs.writeShellApplication rec {
    name = "battery_plugin";
    text = builtins.readFile ./plugins/battery.sh;
    derivationArgs.buildInputs = with pkgs; [
      aerospace
      sketchybar
      gnugrep
    ];

    runtimeInputs = derivationArgs.buildInputs;
  };

  rc = pkgs.writeShellApplication rec {
    name = "sketchybarrc";
    text = builtins.readFile ./sketchybarrc.sh;
    derivationArgs.buildInputs =
      (with pkgs; [
        aerospace
        sketchybar
        gnugrep
      ])
      ++ [
        aerospacePlugin
        appNamePlugin
        clockPlugin
        batteryPlugin
      ];

    runtimeInputs = derivationArgs.buildInputs;
  };
in
{
  config = {
    services.sketchybar = {
      enable = true;
      config = ''
        export THEME_BASE="${theme.base}"
        export THEME_TEXT="${theme.text}"
        export THEME_PINK="${theme.pink}"
        export THEME_SURFACE1="${theme.surface1}"
        sketchybarrc
      '';
      extraPackages = [
        aerospacePlugin
        appNamePlugin
        batteryPlugin
        clockPlugin
        pkgs.gnugrep
        rc
      ];
    };
  };
}
