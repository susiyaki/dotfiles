{ config, pkgs, inputs, ... }:

{
  # Determinate に Nix の管理を任せる
  nix.enable = false;

  system.primaryUser = "laeno";

  environment.systemPackages = with pkgs; [
    vim
    git
    fish
  ];

  programs.fish.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none";
    };

    taps = [
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];

    brews = [
      "sketchybar"
      "ni"  # Fast npm alternative
    ];

    casks = [
      # Window Management
      "aerospace"

      # Terminal & Editor
      "alacritty"

      # Browsers & Communication
      "google-chrome"
      "slack"
      "discord"

      # Utilities
      "1password"
      "1password-cli"
      "karabiner-elements"

      # Entertainment
      "spotify"

      # Development
      "docker-desktop"
      "android-studio"
      "android-platform-tools"

      # Cloud & Infrastructure
      "gcloud-cli"
      "ngrok"
      "session-manager-plugin"

      # Audio
      "blackhole-16ch"

      # Fonts
      "font-hack-nerd-font"
    ];
  };

  system = {
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };

    stateVersion = 5;
  };

  users.users.laeno = {
    name = "laeno";
    home = "/Users/laeno";
  };

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}

