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
    # neovim is configured separately below
    lazygit
    lazydocker
    mise  # Version manager for development tools
    tmux  # Terminal multiplexer

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

    settings = {
      user = {
        name = "susiyaki";
        email = "susiyaki.dev@gmail.com";
      };

      init.defaultBranch = "main";
      pull.rebase = false;
      core.pager = "LESSCHARSET=utf-8 less";

      alias = {
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
      fish_vi_key_bindings

      set -g fish_greeting

      # Set fish_variables to writable location
      set -g fish_variables_path $HOME/.local/share/fish/fish_variables
    '';
  };

  # Starship prompt (disabled - using fish default prompt)
  # programs.starship = {
  #   enable = true;
  #   enableFishIntegration = true;
  # };

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

  # Neovim with proper providers
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withPython3 = true;
    withNodeJs = true;
    withRuby = true;

    extraPython3Packages = (ps: with ps; [
      pynvim
    ]);
  };

  # Tmux (managed via custom config files in OS-specific modules)
  # programs.tmux is disabled to use custom tmux.conf per OS

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
    # Note: tmux config is handled per-OS in darwin.nix and archlinux.nix
  };

  # Note: Alacritty config is handled per-OS in darwin.nix and archlinux.nix
}
