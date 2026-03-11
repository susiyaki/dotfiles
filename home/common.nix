{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  addresses = import ../config/network/addresses.nix;
  nasIp = addresses.tailscale.nas;
  smartphoneIp = addresses.tailscale.smartphone;
  thinkpadP14sIp = addresses.tailscale.thinkpadP14s;
  osLabel = if isDarwin then "macOS" else "Linux";
  fzfCopyCmd = if isDarwin then "pbcopy" else "wl-copy";
  tmuxPasteCmd = if isDarwin then "pbpaste" else "wl-paste";
  shellProgram =
    if isDarwin then "/etc/profiles/per-user/${config.home.username}/bin/fish"
    else "${pkgs.fish}/bin/fish";
  claudeSettingsPath =
    if isDarwin then ../config/claude/settings.darwin.json
    else ../config/claude/settings.linux.json;
  aiAssistant = if isDarwin then "claude" else "claude";
  fzfDefaultOpts = "--preview 'bat --color=always --theme=gruvbox-dark --style=numbers,header --line-range :100 {}' --bind 'ctrl-y:execute: echo {} | ${fzfCopyCmd}' --bind 'ctrl-o:execute: tmux new-window nvim {}'";
  tmuxCopyCommandLine = if isDarwin then "" else "set -s copy-command 'wl-copy'\n";
  alacrittyBase = builtins.fromTOML (builtins.readFile ../config/alacritty/alacritty-base.toml);
  alacrittyShell = {
    terminal.shell.program = shellProgram;
    terminal.shell.args = [ "-l" "-c" "tmux new-session -A -s main" ];
  };
in
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
    FZF_DEFAULT_OPTS = fzfDefaultOpts;
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

    # Claude Code commands
    ".claude/commands" = {
      source = ../config/claude/commands;
      recursive = true;
    };

    # Claude Code hooks
    ".claude/hooks" = {
      source = ../config/claude/hooks;
      recursive = true;
      executable = true;
    };

    ".claude/ha.env".text = ''
      NAS_TAILSCALE_IP=${nasIp}
      SMARTPHONE_TAILSCALE_IP=${smartphoneIp}
      THINKPAD_P14S_TAILSCALE_IP=${thinkpadP14sIp}
      HA_WEBHOOK_URL=http://${nasIp}:8123/api/webhook/claude_code_hook
      CLAUDE_CONFIRM_RESULT_FILE=/home/susiyaki/.local/state/claude/claude_confirm_result.json
    '';

    # Bat (cat replacement)
    ".config/bat".source = ../config/bat;

    # Lazygit
    ".config/lazygit".source = ../config/lazygit;

    # Tmux configuration
    ".config/tmux/tmux-base.conf".source = ../config/tmux/tmux-base.conf;
    ".config/tmux/scripts" = {
      source = ../config/tmux/scripts;
      recursive = true;
    };

    # Neovim skkeleton dictionary path
    ".config/nvim/lua/skkeleton-dict-path.lua".text = ''
      return "${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L"
    '';
  };

  # Claude Code configuration (merge common + OS settings)
  home.file.".claude/settings.local.json".text =
    let
      commonSettings = builtins.fromJSON (builtins.readFile ../config/claude/settings.common.json);
      osSettings = builtins.fromJSON (builtins.readFile claudeSettingsPath);
      mergedSettings = pkgs.lib.recursiveUpdate commonSettings osSettings;
    in
    builtins.toJSON mergedSettings;

  programs.tmux.extraConfig = ''
    # AI Assistant (${osLabel})
    set-environment -g AI_ASSISTANT "${aiAssistant}"
    set -g @ai_assistant "${aiAssistant}"
    set -g @status_left_tail_no_ai "#[fg=#3a3a3a,bg=#262626,nobold]"
    set -g @status_left_tail_ai "#[fg=#3a3a3a,bg=#93a3a2,nobold]#[fg=#262626,bg=#93a3a2,nobold] 󰚩 #{@ai_assistant} #[fg=#93a3a2,bg=#262626,nobold]"
    set -g status-left "#[fg=#262626,bg=#93a3a2,bold]  ${config.home.username}@#h #[fg=#93a3a2,bg=#3a3a3a,nobold]#[fg=#93a3a2,bg=#3a3a3a]  #S #{?#{||:#{||:#{!=:#{@nvim_instance_id},},#{!=:#{@ai_pane_marker},}},#{||:#{==:#{pane_current_command},nvim},#{==:#{pane_current_command},vim}}},#{E:@status_left_tail_ai},#{E:@status_left_tail_no_ai}}"

    # ウィンドウ表示のカスタマイズ（power-themeのフォーマットを上書き）
    set -g window-status-format "#[fg=#93a3a2]#[bg=#3a3a3a] #I #[default]"
    set -g window-status-current-format "#[fg=#262626]#[bg=#93a3a2]#[bold] #I #[default]"
    set -g window-status-separator ""

    # Copy/Paste configuration (${osLabel})
    # Clipboard integration
    set -g set-clipboard on
    set -g allow-passthrough on

    # "y" でヤンク
    ${tmuxCopyCommandLine}
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '${fzfCopyCmd}'

    # "V" で行選択 (行頭起点)
    bind -T copy-mode-vi V send -X start-of-line \; send -X select-line

    # "Y" で行ヤンク (行頭起点 + system clipboard)
    bind -T copy-mode-vi Y send -X start-of-line \; send -X select-line \; send -X copy-pipe-and-cancel '${fzfCopyCmd}'

    # "p"でペースト
    bind p run "tmux set-buffer \"\$(${tmuxPasteCmd})\"; tmux paste-buffer"
  '';

  programs.alacritty = lib.mkIf config.programs.alacritty.enable {
    settings = lib.recursiveUpdate alacrittyBase alacrittyShell;
  };
}
