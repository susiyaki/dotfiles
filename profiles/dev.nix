# profiles/dev.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # From common.nix
    lazygit
    lazydocker
    ni
    tmux
    nodejs_22
    python312
    ruby_3_3
    go
    rustc
    rustup
    deno
    bun
    gh
    act
    awscli2

    # From linux.nix (useful on both)
    android-tools
    dbeaver-bin
    watchman
    claude-code
    gemini-cli
    nixpkgs-fmt
  ];

  programs.fish.shellAliases = {
    # Git shortcuts
    g = "git";
    gs = "git status";
    gd = "git diff";
    nix-format = "nix fmt ~/dotfiles";
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
        ps = "!git push origin `git rev-parse --abbrev-ref HEAD`";
        reb = "rebase";
        res = "restore";
        rehead = "!git reset --hard origin/`git rev-parse --abbrev-ref HEAD`";
        s = "status -s";
        swi = "switch";
        wt = "worktree";
        wtl = "worktree list";
        wtp = "worktree prune";
      };
    };

    ignores = [
      ".DS_Store"
      "Session.vim"
      "**/.claude/settings.local.json"
    ];
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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

  # mise - Version manager for development tools
  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    prefix = "C-q";
    terminal = "screen-256color";
    historyLimit = 10000;
    shell = "${pkgs.fish}/bin/fish";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = yank;
        extraConfig = ''
          # Load base configuration early
          source-file ~/.config/tmux/tmux-base.conf
        '';
      }
      prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_theme '#93a3a2'
          set -g @tmux_power_show_upload_speed true
          set -g @tmux_power_show_download_speed true
          set -g @tmux_power_prefix_highlight_pos 'R'
        '';
      }
      net-speed
      {
        plugin = resurrect.overrideAttrs (old: {
          version = "unstable-2026-01-15";
          src = pkgs.fetchFromGitHub {
            owner = "tmux-plugins";
            repo = "tmux-resurrect";
            rev = "cff343cf9e81983d3da0c8562b01616f12e8d548";
            sha256 = "0djfz7m4l8v2ccn1a97cgss5iljhx9k2p8k9z50wsp534mis7i0m";
          };
          postInstall = ''
            # Remove broken symlinks to test files
            rm -f $target/tests/run_tests_in_isolation
            rm -f $target/tests/helpers/helpers.sh
            rm -f $target/run_tests
          '';
        });
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];
  };
}
