# ============================================================
# Global Environment Variables
# ============================================================
# Note: Basic env vars (LANG, EDITOR, XDG_*) are managed by
# Home Manager. This file only contains PATH settings that
# need runtime detection.

# PATH
set -gx PATH /usr/local/sbin $PATH

# Go
test -d $HOME/go/bin && set -gx PATH $HOME/go/bin $PATH

# Rust (managed outside Nix)
test -d $HOME/.cargo/bin && set -gx PATH $HOME/.cargo/bin $PATH
