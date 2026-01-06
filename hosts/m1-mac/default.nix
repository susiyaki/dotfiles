{ config, pkgs, inputs, ... }:

{
  # Enable experimental features
  nix.settings.experimental-features = "nix-command flakes";

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Homebrew integration
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      "nikitabobko/tap"      # Aerospace
      "FelixKratz/formulae"  # SketchyBar
    ];

    brews = [
      "aerospace"
      "sketchybar"
    ];

    casks = [
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
      "docker"
      "android-studio"
      "android-platform-tools"

      # Cloud & Infrastructure
      "google-cloud-sdk"
      "ngrok"
      "session-manager-plugin"

      # Audio
      "blackhole-16ch"

      # Fonts
      "font-hack-nerd-font"
    ];
  };

  # macOS system settings
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
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };

    stateVersion = 5;
  };

  # User configuration
  users.users.laeno = {
    name = "laeno";
    home = "/Users/laeno";
  };

  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;

  # Used for backwards compatibility
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
