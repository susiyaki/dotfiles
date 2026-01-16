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

    # mise (installed via Nix)
    if command -q mise
      mise activate fish | source
    end
  '';

  # Alacritty configuration
  home.file.".config/alacritty/alacritty-base.toml".source = ../config/alacritty/alacritty-base.toml;

  # Generate alacritty.macos.toml with dynamic username
  home.file.".config/alacritty/alacritty.macos.toml".text = ''
    # ============================================================
    # Alacritty - macOS Specific Configuration
    # ============================================================

    [general]
    import = ["alacritty-base.toml"]

    # Override shell path for macOS (Nix)
    [terminal.shell]
    program = "/etc/profiles/per-user/${config.home.username}/bin/fish"
    args = ["-l", "-c", "tmux new-session -A -s main"]
  '';

  # Set macOS-specific alacritty config as default
  home.file.".config/alacritty/alacritty.toml".text = ''
    [general]
    import = ["alacritty.macos.toml"]
  '';

  # tmux configuration
  home.file.".config/tmux/tmux-base.conf".source = ../config/tmux/tmux-base.conf;

  # Generate tmux.conf with dynamic username
  home.file.".config/tmux/tmux.conf".text = ''
    # Load base configuration
    source-file ~/.config/tmux/tmux-base.conf

    # Shell configuration (Nix-managed fish)
    set-option -g default-shell /etc/profiles/per-user/${config.home.username}/bin/fish
    set-option -g default-command /etc/profiles/per-user/${config.home.username}/bin/fish

    # Copy/Paste configuration (macOS)
    # "y" でヤンク (pbcopy)
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'

    # "Y" で行ヤンク
    bind -T copy-mode-vi Y send -X copy-line

    # "p"でペースト (pbpaste)
    bind p run "tmux set-buffer \"$(pbpaste)\"; tmux paste-buffer"
  '';

  # Karabiner-Elements configuration
  home.file.".config/karabiner" = {
    source = ../config/karabiner;
    recursive = true;
  };
}
