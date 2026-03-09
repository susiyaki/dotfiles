# ============================================================
# Shell Integrations (Common)
# ============================================================
# Note: OS-specific integrations (Homebrew, mise) are managed
# by Home Manager in macos.nix and linux.nix

# SSH Agent (keychain reuses existing ssh-agent across all shells)
if type -q keychain
    keychain --eval --quiet ~/.ssh/github/id_ed25519 2>/dev/null | sed -n 's/^\([A-Z_]*\)="\(.*\)"; export.*/set -gx \1 "\2"/p; s/^\([A-Z_]*\)=\([^;]*\); export.*/set -gx \1 \2/p' | source
end

# GitHub CLI completions (gh is managed by Nix)
eval (gh completion -s fish | source)
