{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Home Manager state version (backwards compatibility)
  # Note: username and homeDirectory are inherited from system configuration
  home.stateVersion = "24.05";

  # Common packages
  home.packages = with pkgs; [
    # Development tools
    neovim
    lazygit
    lazydocker
    mise  # Version manager for development tools

    # Runtimes (managed by mise per-project, but installed via Nix)
    nodejs_22
    python312
    ruby_3_3
    go
    rustc
    cargo
    deno  # JavaScript/TypeScript runtime

    # CLI utilities
    bat
    eza
    ripgrep
    fd
    fzf
    jq
    zoxide
    starship
    tree
    gh      # GitHub CLI
    htop    # System monitor
    wget
    act     # GitHub Actions local runner
    awscli2 # AWS CLI
  ];

  # Common environment variables
  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
    EDITOR = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "susiyaki";
    userEmail = "susiyaki.dev@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.pager = "LESSCHARSET=utf-8 less";
    };

    aliases = {
      a = "add";
      br = "branch";
      c = "commit";
      co = "checkout";
      cp = "cherry-pick";
      fe = "fetch";
      pl = "pull";
      plr = "!git pull origin $(git branch --show-current)";
      ps = "!git push origin `git rev-parse --abbrev-ref HEAD`; gh pr create -w";
      reb = "rebase";
      res = "restore";
      rehead = "!git reset --hard origin/`git rev-parse --abbrev-ref HEAD`";
      s = "status -s";
      swi = "switch";
    };

    ignores = [
      ".DS_Store"
      "Session.vim"
      "**/.claude/settings.local.json"
    ];
  };

  # Fish shell
  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Zoxide (smarter cd)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Tmux
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    mouse = true;
  };

  # Symlink config files
  home.file = {
    ".config/nvim".source = ../config/nvim;
    ".config/fish".source = ../config/fish;
    ".config/tmux".source = ../config/tmux;
  };

  # Note: Alacritty config is handled per-OS in darwin.nix and archlinux.nix
}
