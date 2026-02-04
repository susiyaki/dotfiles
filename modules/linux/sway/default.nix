{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop.sway;
in
{
  options.my.desktop.sway = {
    enable = lib.mkEnableOption "Sway desktop environment";

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "alacritty";
      description = "Default terminal for sway keybindings.";
    };

    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Default font size for sway bars, etc.";
    };
  };

  config = lib.mkIf cfg.enable {
    # This module replaces the need for programs.sway.enable in the NixOS config.
    # It manages the sway config and related packages/services via home-manager.

    home.packages = with pkgs; [
      # Base packages
      sway
      waybar

      # Packages from the old module
      swayidle
      swaybg
      wl-clipboard
      grim
      slurp
      kanshi
      gammastep # Redshift fork with better Wayland support
      wtype # Wayland keyboard input emulator
      libnotify # Desktop notifications
    ];

    # This replaces the home.file link to the sway config dir
    xdg.configFile."sway/config".text = ''
      # Variables
      set $alt Mod1

      set $super Mod4

      set $left h
      set $down j
      set $up k
      set $right l

      set $term ${cfg.terminal}

      # Display
      # output eDP-1 scale 1.5

      # Font
      font pango:monospace ${toString cfg.fontSize}

      # Wallpaper
      output "*" bg ~/.config/sway/wallpaper.png fill

      # Border
      default_border pixel 3
      client.background #24273a
      client.focused #b8c0e0 #b8c0e0 #494d64
      client.focused_inactive #8087a2 #8087a2 #000000
      client.unfocused #494d64 #494d64 b8c0e0
      client.urgent #ee99a0 #cad3f5 #000000


      # Custom keybindings
      ## Basics
      bindsym XF86MonBrightnessDown exec brightnessctl set 3%-
      bindsym XF86MonBrightnessUp exec brightnessctl set 3%+
      bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+
      bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
      bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next
      bindsym XF86AudioPrev exec playerctl previous
      ### display color temperature
      bindsym XF86Display exec systemctl --user is-active gammastep.service && systemctl --user stop gammastep.service || systemctl --user start gammastep.service
      ### notification
      bindsym $super+n exec swaync-client -t -sw
      bindsym $super+d exec swaync-client -d

      ## Sway
      ### Use Mouse+$alt to drag floating windows to theier wanted position
      floating_modifier $alt normal
      ### Reload the configuration file
      bindsym $alt+Shift+c reload
      ### Exit sway (logs you out of your Wayland session)
      bindsym $alt+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'

      ## Screenshots & Screencasts
      # Screenshot/screencast to clipboard (no Shift)
      bindsym Print exec bash ~/.config/sway/scripts/capture-manager.sh screenshot --clipboard
      bindsym Ctrl+Print exec bash ~/.config/sway/scripts/capture-manager.sh screencast --clipboard
      # Screenshot/screencast to file (with Shift)
      bindsym Shift+Print exec bash ~/.config/sway/scripts/capture-manager.sh screenshot --save
      bindsym Ctrl+Shift+Print exec bash ~/.config/sway/scripts/capture-manager.sh screencast --save

      ## Logout
      bindsym $alt+Shift+delete exec wlogout

      ## Launcher
      bindsym $super+space exec wofi --show drun

      ## Filer
      bindsym $super+e exec thunar

      # Clipboard
      bindsym Control+semicolon exec clipman pick -t wofi -T'--prompt=clipboard-history -i'

      # Bluetooth
      for_window [app_id="blueman-manager"] floating enable

      # 1Password
      for_window [class="1Password"] floating enable

      ## App shortcuts
      bindsym $super+Return exec $term
      bindsym $alt+Ctrl+t exec bash ~/.config/sway/scripts/focus_or_open $term
      bindsym $alt+Ctrl+b exec bash ~/.config/sway/scripts/focus_or_open google-chrome-stable
      bindsym $alt+Ctrl+s exec bash ~/.config/sway/scripts/focus_or_open slack
      bindsym $alt+Ctrl+d exec bash ~/.config/sway/scripts/focus_or_open discord
      bindsym $alt+Ctrl+m exec bash ~/.config/sway/scripts/focus_or_open spotify-launcher

      ## Kill focused window
      bindsym $alt+Shift+q kill

      # Moving
      # Move your focus around
      bindsym $alt+$left focus left
      bindsym $alt+$down focus down
      bindsym $alt+$up focus up
      bindsym $alt+$right focus right
      # Or use $alt+[up|down|left|right]
      bindsym $alt+Left focus left
      bindsym $alt+Down focus down
      bindsym $alt+Up focus up
      bindsym $alt+Right focus right

      # Move the focused window with the same, but add Shift
      bindsym $alt+Shift+$left move left
      bindsym $alt+Shift+$down move down
      bindsym $alt+Shift+$up move up
      bindsym $alt+Shift+$right move right
      # Ditto, with arrow keys
      bindsym $alt+Shift+Left move left
      bindsym $alt+Shift+Down move down
      bindsym $alt+Shift+Up move up
      bindsym $alt+Shift+Right move right

      # Workspace
      # Switch to workspace
      bindsym $alt+1 workspace number 1
      bindsym $alt+2 workspace number 2
      bindsym $alt+3 workspace number 3
      bindsym $alt+4 workspace number 4
      bindsym $alt+5 workspace number 5
      bindsym $alt+6 workspace number 6
      bindsym $alt+7 workspace number 7
      bindsym $alt+8 workspace number 8
      bindsym $alt+9 workspace number 9
      bindsym $alt+0 workspace number 10
      # Move focused container to workspace
      bindsym $alt+Shift+1 move container to workspace number 1
      bindsym $alt+Shift+2 move container to workspace number 2
      bindsym $alt+Shift+3 move container to workspace number 3
      bindsym $alt+Shift+4 move container to workspace number 4
      bindsym $alt+Shift+5 move container to workspace number 5
      bindsym $alt+Shift+6 move container to workspace number 6
      bindsym $alt+Shift+7 move container to workspace number 7
      bindsym $alt+Shift+8 move container to workspace number 8
      bindsym $alt+Shift+9 move container to workspace number 9
      bindsym $alt+Shift+0 move container to workspace number 10

      # Layout & Scratchpad
      ## to container
      bindsym $alt+Shift+equal floating toggle
      ## to scratchpad
      bindsym $alt+Shift+minus move scratchpad
      ## show scratchpad
      bindsym $alt+space scratchpad show

      ## Layout
      bindsym $alt+s layout stacking
      bindsym $alt+w layout tabbed
      bindsym $alt+e layout toggle split

      ## Make the current focus fullscreen
      bindsym $alt+f fullscreen

      # Resize
      bindsym $alt+r mode "resize"
      mode "resize" {
        # left will shrink the containers width
        # right will grow the containers width
        # up will shrink the containers height
        # down will grow the containers height
        bindsym $left resize shrink width 10px
        bindsym $down resize grow height 10px
        bindsym $up resize shrink height 10px
        bindsym $right resize grow width 10px

        # Ditto, with arrow keys
        bindsym Left resize shrink width 10px
        bindsym Down resize grow height 10px
        bindsym Up resize shrink height 10px
        bindsym Right resize grow width 10px

        # Return to default mode
        bindsym Return mode "default"
        bindsym Escape mode "default"
      }

      # Status bar
      bar {
        swaybar_command waybar
      }

      # Keyboard & Touchpad
      input type:keyboard {
        repeat_delay 300
        repeat_rate 50
      }

      input type:touchpad {
        tap enabled
        dwt enabled
        natural_scroll enabled
        pointer_accel 0.35
      }

      # sway-session
      exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      exec_always "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP; systemctl --user start sway-session.target"
      exec swaync
      exec swayidle -w timeout 300 'swaylock -f' timeout 1200 'systemctl suspend'
      exec blueman-applet
      exec wl-paste -t text --watch ~/.config/sway/scripts/myclipman.sh
      exec nm-applet --indicator
      exec_always kanshi
      exec_always fcitx5 -d --replace

      include /etc/sway/config.d/*
    '';

    # Keep other sway-related configs from the old module
    # Note: The main sway config is now handled by xdg.configFile above, so the original link is removed.
    home.file.".config/swaync".source = ../../../config/swaync;
    home.file.".config/kanshi".source = ../../../config/kanshi;
    home.file.".config/sway/scripts".source = ../../../config/sway/scripts;


    # Keep systemd services from the old module
    systemd.user.targets.sway-session = {
      Unit = {
        Description = "Sway compositor session";
        Documentation = "man:systemd.special";
        BindsTo = "graphical-session.target";
        Wants = "graphical-session-pre.target";
        After = "graphical-session-pre.target";
      };
    };

    systemd.user.services = {
      kanshi = {
        Unit = {
          Description = "Dynamic output configuration for Wayland compositors";
          Documentation = "https://sr.ht/~emersion/kanshi";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.kanshi}/bin/kanshi";
          Restart = "always";
          RestartSec = 5;
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
      gammastep = {
        Unit = {
          Description = "Control display color temperature with gammastep";
          Documentation = "https://gitlab.com/chinstrap/gammastep";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.gammastep}/bin/gammastep";
          Restart = "always";
          RestartSec = 5;
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
    };
  };
}
