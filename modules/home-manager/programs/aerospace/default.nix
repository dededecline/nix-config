{pkgs, ...}: let
  sb = "${pkgs.sketchybar}/bin/sketchybar";
  trigger-workspace-change = "${sb} --trigger aerospace_workspace_change";
  trigger-workspace-monitor-change = "${sb} --trigger aerospace_workspace_monitor_change";
in {
  programs.aerospace = {
    enable = true;
    userSettings = ''
      start-at-login = true

      enable-normalization-flatten-containers = true
      enable-normalization-opposite-orientation-for-nested-containers = true

      accordion-padding = 30

      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"]

      automatically-unhide-macos-hidden-apps = true

      [gaps]
      inner.horizontal = 6
      inner.vertical =   6
      outer.left =       6
      outer.bottom =     6
      outer.top =        6
      outer.right =      6

      [mode.main.binding]
      alt-i = "focus up"
      alt-j = "focus left"
      alt-k = "focus down"
      alt-l = "focus right"

      alt-ctrl-shift-f = "fullscreen"
      alt-ctrl-f = "layout floating tiling"

      alt-ctrl-shift-i = "join-with up"
      alt-ctrl-shift-j = "join-with left"
      alt-ctrl-shift-k = "join-with down"
      alt-ctrl-shift-l = "join-with right"

      alt-slash = "layout tiles horizontal vertical"
      alt-comma = "layout accordion horizontal vertical"

      alt-shift-i = "move up"
      alt-shift-j = "move left"
      alt-shift-k = "move down"
      alt-shift-l = "move right"

      alt-shift-minus = "resize smart -50"
      alt-shift-equal = "resize smart +50"

      alt-q = "workspace 1"
      alt-w = "workspace 2"
      alt-e = "workspace 3"
      alt-r = "workspace 4"
      alt-t = "workspace 5"
      alt-y = "workspace 6"

      alt-shift-q = "move-node-to-workspace 1 --focus-follows-window"
      alt-shift-w = "move-node-to-workspace 2 --focus-follows-window"
      alt-shift-e = "move-node-to-workspace 3 --focus-follows-window"
      alt-shift-r = "move-node-to-workspace 4 --focus-follows-window"
      alt-shift-t = "move-node-to-workspace 5 --focus-follows-window"
      alt-shift-y = "move-node-to-workspace 6 --focus-follows-window"

      alt-tab = "workspace-back-and-forth"
      alt-shift-tab = [
        "move-workspace-to-monitor --wrap-around next"
        "exec-and-forget ${trigger-workspace-monitor-change}"
      ]

      alt-shift-semicolon = "mode service"

      [workspace-to-monitor-force-assignment]
      1 = "main"
      2 = "main"
      3 = "main"
      4 = "main"
      5 = [
        "secondary",
        "main"
      ]
      6 = [
        "secondary",
        "main"
      ]

      exec-on-workspace-change = [
        "/bin/bash",
        "-c",
        "${trigger-workspace-change} FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ]

      [mode.service.binding]
      esc = ["reload-config", "mode main"]
      r = ["flatten-workspace-tree", "mode main"]
      f = ["layout floating tiling", "mode main"]
      backspace = ["close-all-windows-but-current", "mode main"]

      [[on-window-detected]]
      if.app-id = "us.zoom.xos"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.1password.1password"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.apple.finder"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.iconfactory.Tot"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "org.via.configurator"
      run = "layout floating"

      [[on-window-detected]]
      if.app-name-regex-substring = "Vial"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.protonmail.bridge"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.valvesoftware.steam"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.apple.mail"
      run = "move-node-to-workspace 1"

      [[on-window-detected]]
      if.app-id = "com.apple.iCal"
      run = "move-node-to-workspace 1"

      [[on-window-detected]]
      if.app-id = "ch.protonmail.desktop"
      run = "move-node-to-workspace 1"

      [[on-window-detected]]
      if.app-id = "com.hnc.Discord"
      run = "move-node-to-workspace 2"

      [[on-window-detected]]
      if.app-id = "com.apple.MobileSMS"
      run = "move-node-to-workspace 2"

      [[on-window-detected]]
      if.app-id = "com.tinyspeck.slackmacgap"
      run = "move-node-to-workspace 3"

      [[on-window-detected]]
      if.app-id = "org.whispersystems.signal-desktop"
      run = "move-node-to-workspace 3"

      [[on-window-detected]]
      if.app-id = "com.Balatro.localthunk"
      run = "move-node-to-workspace 6"
    '';
  };
}
