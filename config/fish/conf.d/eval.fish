# ============================================================
# Shell Integrations (Common)
# ============================================================
# Note: OS-specific integrations (Homebrew, mise) are managed
# by Home Manager in macos.nix and linux.nix

# SSH Agent
eval (ssh-agent -c) >/dev/null

# GitHub CLI completions (gh is managed by Nix)
eval (gh completion -s fish | source)
