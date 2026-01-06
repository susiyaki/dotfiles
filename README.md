# Laeno's Dotfiles

Clean, Nix-based dotfiles for managing both macOS and Linux systems.

## Structure

```
dotfiles-new/
├── flake.nix              # Root flake managing all systems
├── hosts/                 # System-specific configurations
│   ├── m1-mac/           # macOS (nix-darwin)
│   └── thinkpad-p14s/    # Linux (NixOS)
├── home/                  # Home Manager configurations
│   ├── common.nix        # Shared config
│   ├── macos.nix         # macOS-specific
│   └── linux.nix         # Linux-specific
├── modules/               # Feature modules
│   ├── macos/            # macOS-only modules
│   │   ├── aerospace/
│   │   └── sketchybar/
│   └── linux/            # Linux-only modules
│       ├── sway/
│       └── waybar/
└── config/                # Actual configuration files
    ├── nvim/             # Shared
    ├── fish/             # Shared
    ├── git/              # Shared
    ├── alacritty/        # Shared
    ├── tmux/             # Shared
    ├── aerospace/        # macOS-only
    ├── sketchybar/       # macOS-only
    ├── sway/             # Linux-only
    └── waybar/           # Linux-only
```

## Quick Start

### Prerequisites

**Install Nix:**
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart your shell:
```bash
exec $SHELL
```

### macOS (M1 Mac)

```bash
# First time setup
nix run nix-darwin -- switch --flake ~/dotfiles-new#m1-mac

# Subsequent updates
darwin-rebuild switch --flake ~/dotfiles-new
```

### Linux (ThinkPad P14s Gen4)

**First, generate hardware config on your Linux machine:**
```bash
sudo nixos-generate-config --show-hardware-config > ~/dotfiles-new/hosts/thinkpad-p14s/hardware.nix
```

**Then build:**
```bash
# First time setup
sudo nixos-rebuild switch --flake ~/dotfiles-new#thinkpad-p14s

# Subsequent updates
sudo nixos-rebuild switch --flake ~/dotfiles-new
```

## What's Managed

### Common (Both macOS and Linux)
- **Editors**: Neovim
- **Shell**: Fish with Starship prompt
- **Terminal**: Alacritty
- **Multiplexer**: Tmux
- **Version Control**: Git
- **CLI Tools**: bat, eza, ripgrep, fd, fzf, zoxide, lazygit

### macOS-Specific
- **Window Manager**: Aerospace
- **Status Bar**: SketchyBar
- **System Settings**: Dock, Finder, Keyboard
- **GUI Apps**: Chrome, Slack, Discord, Spotify, 1Password (via Homebrew)

### Linux-Specific
- **Window Manager**: Sway (Wayland)
- **Status Bar**: Waybar
- **Notifications**: swaync
- **Display Management**: Kanshi
- **Input Method**: Fcitx5 with Mozc

## Daily Workflow

### Update Configuration

After modifying any config files:

**macOS:**
```bash
darwin-rebuild switch --flake ~/dotfiles-new
```

**Linux:**
```bash
sudo nixos-rebuild switch --flake ~/dotfiles-new
```

### Update All Packages

```bash
cd ~/dotfiles-new
nix flake update
# Then rebuild as above
```

### Rollback

**macOS:**
```bash
darwin-rebuild switch --rollback
```

**Linux:**
```bash
sudo nixos-rebuild switch --rollback
```

## Adding New Configurations

### Add a New Package

**Common (both systems):**
Edit `home/common.nix`:
```nix
home.packages = with pkgs; [
  # existing packages...
  htop  # add this
];
```

**macOS only:**
Edit `hosts/m1-mac/default.nix`:
```nix
homebrew.casks = [
  "visual-studio-code"  # add this
];
```

### Add a New Config File

1. Place config in `config/` directory
2. Add symlink in appropriate module:
   - For shared: `home/common.nix`
   - For macOS: `modules/macos/<module>/default.nix`
   - For Linux: `modules/linux/<module>/default.nix`

Example:
```nix
home.file.".config/myapp".source = ../config/myapp;
```

## Migration from Old Dotfiles

This is a clean rewrite without chezmoi. The old dotfiles (with `dot_` prefixes) are kept in `~/dotfiles` for reference.

Key differences:
- ✅ No `dot_` prefixes
- ✅ Pure Nix management (no chezmoi)
- ✅ Multi-system support in single repo
- ✅ Declarative everything
- ✅ Easy rollbacks

## Tips

### Test Before Applying
```bash
# macOS
darwin-rebuild build --flake ~/dotfiles-new

# Linux
sudo nixos-rebuild build --flake ~/dotfiles-new
```

### Check for Errors
```bash
nix flake check
```

### Clean Up Old Generations
```bash
nix-collect-garbage -d
sudo nix-collect-garbage -d  # Linux only
```

### View Configuration
```bash
# macOS
darwin-rebuild --list-generations

# Linux
sudo nixos-rebuild list-generations
```

## Branches

- **main**: Clean Nix-based dotfiles (this repo)
- **m1-mac**: Old chezmoi-based macOS config (archived)
- **thinkpad-p14s-gen4**: Old chezmoi-based Linux config (archived)

## Resources

- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)

## License

MIT
