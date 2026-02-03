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

    # fzf - Uses macOS native pbcopy
    FZF_DEFAULT_OPTS = "--preview 'bat --color=always --theme=gruvbox-dark --style=numbers,header --line-range :100 {}' --bind 'ctrl-y:execute: echo {} | pbcopy' --bind 'ctrl-o:execute: tmux new-window nvim {}'";
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
  programs.tmux.extraConfig = ''
    # AI Assistant (macOS)
    set-environment -g AI_ASSISTANT "claude"

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

  home.file.".config/tmux/tmux-base.conf".source = ../config/tmux/tmux-base.conf;
  home.file.".config/tmux/scripts" = {
    source = ../config/tmux/scripts;
    recursive = true;
  };

  # Karabiner-Elements configuration
  # $HOMEを動的に置換して生成
  home.file.".config/karabiner/karabiner.json".text =
    let
      karabinerConfig = builtins.readFile ../config/karabiner/karabiner.json;
      homeDir = config.home.homeDirectory;
    in
      builtins.replaceStrings ["$HOME"] [homeDir] karabinerConfig;

  # Claude Code configuration (merge common + darwin settings)
  home.file.".claude/settings.json".text =
    let
      commonSettings = builtins.fromJSON (builtins.readFile ../config/claude/settings.common.json);
      darwinSettings = builtins.fromJSON (builtins.readFile ../config/claude/settings.darwin.json);
      mergedSettings = pkgs.lib.recursiveUpdate commonSettings darwinSettings;
    in
      builtins.toJSON mergedSettings;

  # Gemini CLI configuration (merge common + darwin settings)
  home.file.".gemini/settings.json" = {
    text =
      let
        commonSettings = builtins.fromJSON (builtins.readFile ../config/gemini/settings.common.json);
        darwinSettings = builtins.fromJSON (builtins.readFile ../config/gemini/settings.darwin.json);
        mergedSettings = pkgs.lib.recursiveUpdate commonSettings darwinSettings;
      in
        builtins.toJSON mergedSettings;
    force = true;
  };

  # Neovim skkeleton dictionary path
  home.file.".config/nvim/lua/skkeleton-dict-path.lua".text = ''
    return "${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L"
  '';
}
