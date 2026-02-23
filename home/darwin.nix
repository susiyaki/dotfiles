{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ../profiles/cli.nix
    ../profiles/dev.nix
    ../modules/darwin/aerospace
    ../modules/darwin/sketchybar
  ];

  # macOS-specific packages
  home.packages = with pkgs; [
    # Fonts (via Nix)
    # Note: Hack Nerd Font is installed via Homebrew cask for better integration
    skkDictionaries.l
  ];

  # macOS-specific environment variables
  home.sessionVariables = {
    # Android SDK (macOS)
    ANDROID_HOME = "$HOME/Library/Android/sdk";
    ANDROID_SDK_ROOT = "$HOME/Library/Android/sdk";
  };

  # macOS-specific fish aliases
  programs.fish.shellAliases = {
    nix-switch = "cd ~/dotfiles && nix build .#darwinConfigurations.m1-mac.system && sudo ./result/sw/bin/darwin-rebuild switch --flake ~/dotfiles#m1-mac";
  };

  # macOS-specific shell config
  programs.fish.loginShellInit = ''
    # Nix paths (must be set early)
    set -gx PATH /etc/profiles/per-user/laeno/bin $PATH
    set -gx PATH /run/current-system/sw/bin $PATH
    set -gx PATH /nix/var/nix/profiles/default/bin $PATH
  '';

  programs.fish.shellInit = ''
    # Homebrew paths
    eval (/opt/homebrew/bin/brew shellenv)
  '';

  # Karabiner-Elements configuration
  # $HOMEを動的に置換して生成
  home.file.".config/karabiner/karabiner.json".text =
    let
      karabinerConfig = builtins.readFile ../config/karabiner/karabiner.json;
      homeDir = config.home.homeDirectory;
    in
    builtins.replaceStrings [ "$HOME" ] [ homeDir ] karabinerConfig;

}
