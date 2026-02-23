{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  osLabel = if isDarwin then "macOS" else "Linux";
  fzfCopyCmd = if isDarwin then "pbcopy" else "wl-copy";
  tmuxPasteCmd = if isDarwin then "pbpaste" else "wl-paste";
  shellProgram =
    if isDarwin then "/etc/profiles/per-user/${config.home.username}/bin/fish"
    else "${pkgs.fish}/bin/fish";
  claudeSettingsPath =
    if isDarwin then ../config/claude/settings.darwin.json
    else ../config/claude/settings.linux.json;
  geminiSettingsPath =
    if isDarwin then ../config/gemini/settings.darwin.json
    else ../config/gemini/settings.linux.json;
  aiAssistant = if isDarwin then "claude" else "codex";
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
  home.file.".claude/settings.json".text =
    let
      commonSettings = builtins.fromJSON (builtins.readFile ../config/claude/settings.common.json);
      osSettings = builtins.fromJSON (builtins.readFile claudeSettingsPath);
      mergedSettings = pkgs.lib.recursiveUpdate commonSettings osSettings;
    in
    builtins.toJSON mergedSettings;

  # Gemini CLI configuration (merge common + OS settings)
  home.file.".gemini/settings.json" = {
    text =
      let
        commonSettings = builtins.fromJSON (builtins.readFile ../config/gemini/settings.common.json);
        osSettings = builtins.fromJSON (builtins.readFile geminiSettingsPath);
        mergedSettings = pkgs.lib.recursiveUpdate commonSettings osSettings;
      in
      builtins.toJSON mergedSettings;
    force = true;
  };

  programs.tmux.extraConfig = ''
    # AI Assistant (${osLabel})
    set-environment -g AI_ASSISTANT "${aiAssistant}"

    # Copy/Paste configuration (${osLabel})
    # "y" でヤンク
    ${tmuxCopyCommandLine}
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '${fzfCopyCmd}'

    # "Y" で行ヤンク
    bind -T copy-mode-vi Y send -X copy-line

    # "p"でペースト
    bind p run "tmux set-buffer \"\$(${tmuxPasteCmd})\"; tmux paste-buffer"
  '';

  programs.alacritty = lib.mkIf config.programs.alacritty.enable {
    settings = lib.recursiveUpdate alacrittyBase alacrittyShell;
  };
}
