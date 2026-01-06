{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/darwin/aerospace
    ../modules/darwin/sketchybar
  ];

  # macOS-specific packages
  home.packages = with pkgs; [
    # Fonts (via Nix)
    # Note: Hack Nerd Font is installed via Homebrew cask for better integration
  ];

  # macOS-specific environment variables
  home.sessionVariables = {
    # Android SDK (macOS)
    ANDROID_HOME = "$HOME/Library/Android/sdk";
    ANDROID_SDK_ROOT = "$HOME/Library/Android/sdk";
  };

  # macOS-specific shell config
  programs.fish.shellInit = ''
    # Homebrew paths
    eval (/opt/homebrew/bin/brew shellenv)

    # mise (macOS)
    if test -f "/opt/homebrew/opt/mise/bin/mise"
      /opt/homebrew/opt/mise/bin/mise activate fish | source
    end
  '';

  # Alacritty - use macOS-specific config
  home.file.".config/alacritty" = {
    source = ../config/alacritty;
    recursive = true;
  };

  # Set macOS-specific alacritty config as default
  home.file.".config/alacritty/alacritty.toml".text = ''
    import = ["alacritty.macos.yml"]
  '';

  # Karabiner-Elements configuration
  home.file.".config/karabiner" = {
    source = ../config/karabiner;
    recursive = true;
  };
}
