{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Home Manager state version (backwards compatibility)
  # Note: username and homeDirectory are inherited from system configuration
  home.stateVersion = "24.05";

  # Common environment variables
  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
    EDITOR = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";

    # FZF_DEFAULT_OPTS is defined in OS-specific configs (darwin.nix/linux.nix)
    # because it uses OS-specific clipboard commands (pbcopy/wl-copy)
  };

  # Fish shell
  programs.fish = {
    enable = true;
    # Aliases are now in profiles/cli.nix and profiles/dev.nix
    shellAliases = { };
    loginShellInit = ''
      # Source Home Manager session variables
      if test -f ~/.nix-profile/etc/profile.d/hm-session-vars.fish
        source ~/.nix-profile/etc/profile.d/hm-session-vars.fish
      end
    '';
    shellInit = ''
      fish_vi_key_bindings

      set -g fish_greeting

      # Set fish_variables to writable location
      set -g fish_variables_path $HOME/.local/share/fish/fish_variables
    '';
  };

  # Bash shell
  programs.bash = {
    enable = true;
    initExtra = ''
      # Source Home Manager session variables
      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi
    '';
  };

  # Symlink config files
  home.file = {
    ".config/nvim" = {
      source = ../config/nvim;
      recursive = true;
    };

    # Fish is managed by programs.fish, not symlinking
    # ".config/fish".source = ../config/fish;
    ".config/fish/conf.d".source = ../config/fish/conf.d;
    ".config/fish/functions".source = ../config/fish/functions;
    # Note: tmux config is handled per-OS in darwin.nix and linux.nix

    # Claude Code commands
    ".claude/commands" = {
      source = ../config/claude/commands;
      recursive = true;
    };

    # Bat (cat replacement)
    ".config/bat".source = ../config/bat;

    # Lazygit
    ".config/lazygit".source = ../config/lazygit;
  };

  # Note: Alacritty config is handled per-OS in darwin.nix and linux.nix
}