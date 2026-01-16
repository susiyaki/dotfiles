# Dotfiles

Clean, Nix-based dotfiles for managing both macOS and Linux systems.

## 📦 Systems

| System | Host | Architecture | Manager |
|--------|------|--------------|---------|
| macOS M1 | m1-mac | aarch64-darwin | nix-darwin |
| ThinkPad P14s Gen 5 AMD | thinkpad-p14s | x86_64-linux | home-manager on Arch Linux |

## 🚀 Quick Start

### Prerequisites

Install Nix (using Determinate Systems installer):
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
exec $SHELL
```

### macOS Setup

```bash
# Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Initial setup
nix run nix-darwin -- switch --flake ~/dotfiles#m1-mac

# Reload shell to enable nix-switch command
exec $SHELL

# Use nix-switch for subsequent updates
nix-switch
```

### Linux Setup (Arch Linux + home-manager)

```bash
# Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Initial home-manager setup
nix run home-manager/master -- switch --flake ~/dotfiles#susiyaki@thinkpad-p14s

# Reload shell to enable nix-switch command
exec $SHELL

# Use nix-switch for subsequent updates
nix-switch

# System packages are still managed via pacman
sudo pacman -S sway waybar gdm pipewire fcitx5-mozc blueman tlp
```

See [docs/arch-linux-setup.md](docs/arch-linux-setup.md) for detailed Linux setup instructions.

## 📁 Structure

```
dotfiles/
├── flake.nix              # Root flake managing all systems
├── hosts/                 # System-specific configurations
│   ├── m1-mac/           # macOS (nix-darwin)
│   │   └── default.nix
│   └── thinkpad-p14s/    # Linux (home-manager)
│       ├── default.nix
│       └── hardware.nix
├── home/                  # Home Manager configurations
│   ├── common.nix        # Shared config
│   ├── darwin.nix        # macOS-specific
│   └── archlinux.nix     # Linux-specific
├── modules/               # Feature modules
│   ├── darwin/           # macOS-only modules
│   │   ├── aerospace/
│   │   └── sketchybar/
│   └── archlinux/        # Linux-only modules
│       ├── sway/
│       ├── waybar/
│       └── i3/           # Alternative (disabled)
└── config/                # Actual configuration files
    ├── nvim/             # Shared
    ├── fish/             # Shared
    ├── alacritty/        # Shared (OS-specific imports)
    ├── tmux/             # Shared
    ├── aerospace/        # macOS-only
    ├── sketchybar/       # macOS-only
    ├── karabiner/        # macOS-only
    ├── sway/             # Linux-only
    ├── waybar/           # Linux-only
    ├── swaync/           # Linux-only
    └── kanshi/           # Linux-only
```

## 🔄 Daily Workflow

### Update Configuration

After modifying any config files:

```bash
# Both macOS and Linux
nix-switch
```

### Update All Packages

```bash
cd ~/dotfiles
nix flake update
nix-switch
```

### Rollback

**macOS:**
```bash
darwin-rebuild switch --rollback
```

**Linux:**
```bash
home-manager switch --rollback
```

### Clean Up Old Generations

```bash
nix-collect-garbage -d
```

## 🛠️ What's Managed

### Common (Both macOS and Linux)

| Category | Tools |
|----------|-------|
| **Editor** | Neovim |
| **Shell** | Fish with Starship prompt |
| **Terminal** | Alacritty (OS-specific configs) |
| **Multiplexer** | Tmux |
| **Version Control** | Git, gh CLI |
| **Development** | Node.js 22, Python 3.12, Ruby 3.3, Go, Rust, Deno |
| **Version Manager** | mise (per-project runtimes) |
| **CLI Tools** | bat, eza, ripgrep, fd, fzf, zoxide, lazygit, lazydocker, jq |
| **Cloud** | AWS CLI v2 |

### macOS-Specific

| Category | Tools |
|----------|-------|
| **Window Manager** | Aerospace (tiling) |
| **Status Bar** | SketchyBar |
| **Keyboard** | Karabiner-Elements |
| **System Settings** | Dock, Finder, Keyboard |
| **GUI Apps** | Chrome, Slack, Discord, Spotify, 1Password |
| **Development** | Android Studio, Docker Desktop |

### Linux-Specific (ThinkPad P14s)

| Category | Tools |
|----------|-------|
| **Window Manager** | Sway (Wayland compositor) |
| **Status Bar** | Waybar |
| **Notifications** | swaync |
| **Display Management** | Kanshi |
| **Input Method** | Fcitx5 with Mozc (Japanese) |
| **Power Management** | TLP |
| **Audio** | PipeWire with PulseAudio |
| **Bluetooth** | Blueman |
| **Launcher** | wofi / rofi-wayland |
| **File Manager** | Thunar |
| **GUI Apps** | Firefox, Discord, DBeaver, Postman |
| **Media** | Celluloid, MPV, imv |
| **Utilities** | brightnessctl, pavucontrol, btop, nvtop |
| **Theme** | Adwaita Dark |

## ⚡ Key Features

### ThinkPad P14s Optimizations
- AMD optimized with native amdgpu drivers
- Battery management with TLP (75-80% charge thresholds)
- Btrfs with Zstd compression and monthly scrubbing
- Zram with 50% memory compression
- Wayland native (all apps)
- Unified Adwaita Dark theme
- Japanese input with Fcitx5 + Mozc

### Cross-Platform Benefits
- Declarative package and config management
- Atomic updates with rollback capability
- Single repository for both systems
- Reproducible environments
- Version controlled configuration

## 📝 Adding New Configurations

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
   - For macOS: `modules/darwin/<module>/default.nix`
   - For Linux: `modules/archlinux/<module>/default.nix`

Example:
```nix
home.file.".config/myapp".source = ../config/myapp;
```

## 🔍 Tips

### Test Before Applying

```bash
# macOS
darwin-rebuild build --flake ~/dotfiles

# Linux
home-manager build --flake ~/dotfiles
```

### Check for Errors

```bash
nix flake check
```

### View Generations

```bash
# macOS
darwin-rebuild --list-generations

# Linux
home-manager generations
```

## 📚 Resources

- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)

## 📄 License

MIT
