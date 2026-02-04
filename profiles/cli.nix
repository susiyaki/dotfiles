# profiles/cli.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    eza
    ripgrep
    fd
    fzf
    jq
    starship
    tree
    htop
    wget
  ];

  home.sessionVariables = {
    # fzf - Fuzzy finder
    FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --no-ignore-vcs --follow -g '!node_modules/*' -g '!.git/*'";
    FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'";
  };

  programs.fish.shellAliases = {
    # Common shortcuts
    ls = "eza --icons";
    ll = "eza -l --icons";
    la = "eza -la --icons";
    cat = "bat";
  };

  # Zoxide (smarter cd)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Starship prompt (disabled - using fish default prompt)
  # programs.starship = {
  #   enable = true;
  #   enableFishIntegration = true;
  # };
}
