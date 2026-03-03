# ============================================================
# Shell Integrations (Common)
# ============================================================
# Note: OS-specific integrations (Homebrew, mise) are managed
# by Home Manager in macos.nix and linux.nix

# SSH Agent (keychain reuses existing ssh-agent across all shells)
if type -q keychain
    keychain --eval --quiet ~/.ssh/github/id_ed25519 | source
end

# GitHub CLI completions (gh is managed by Nix)
eval (gh completion -s fish | source)
