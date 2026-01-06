# Dotfiles

Clean, Nix-based dotfiles for managing both macOS and Linux systems.

## Systems

- **m1-mac**: M1 Mac (aarch64-darwin) with nix-darwin
- **thinkpad-p14s**: ThinkPad P14s Gen 5 AMD (x86_64-linux) with NixOS

## Structure

```
dotfiles-new/
├── flake.nix              # Root flake managing all systems
├── hosts/                 # System-specific configurations
│   ├── m1-mac/           # macOS (nix-darwin)
│   │   └── default.nix
│   └── thinkpad-p14s/    # Linux (NixOS)
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

### Linux (ThinkPad P14s Gen 5 AMD)

#### Hardware Specifications
- CPU: AMD Ryzen 7 PRO 7840U (8C/16T)
- GPU: AMD Radeon 780M Graphics
- RAM: 28GB
- Storage: NVMe SSD (Btrfs)
- Display: Natural scrolling touchpad enabled

#### Recommended: Arch Linux + home-manager

**現在のArch Linuxをそのまま使用し、home-managerでdotfilesだけを管理します。**

詳細な手順は [docs/arch-linux-setup.md](docs/arch-linux-setup.md) を参照してください。

**クイックスタート：**

```bash
# 1. Nixをインストール
sh <(curl -L https://nixos.org/nix/install) --daemon
exec $SHELL

# 2. dotfilesをクローン
git clone https://github.com/yourusername/dotfiles-new.git ~/dotfiles-new

# 3. home-managerを適用
nix run home-manager/master -- switch --flake ~/dotfiles-new#susiyaki@thinkpad-p14s

# 4. システムパッケージは引き続きpacmanで管理
sudo pacman -S sway waybar gdm pipewire fcitx5-mozc blueman tlp
```

**メリット：**
- システム再インストール不要
- Arch Linuxの柔軟性を維持
- dotfilesをNixで宣言的に管理
- pacmanとNixを併用可能

#### Alternative: Fresh NixOS Installation

完全なシステムレベルの再現性が必要な場合のみ推奨。

1. Boot from NixOS installer USB
2. Partition and format disks:
```bash
# Example partitioning (adjust as needed)
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary btrfs 512MB 100%

mkfs.vfat -n boot /dev/nvme0n1p1
mkfs.btrfs -L nixos /dev/nvme0n1p2
```

3. Mount and generate config:
```bash
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

nixos-generate-config --root /mnt
```

4. Clone dotfiles and use our configuration:
```bash
cd /mnt/home
git clone https://github.com/yourusername/dotfiles-new
cd dotfiles-new

# Optionally, update hardware.nix with generated config
# cp /mnt/etc/nixos/hardware-configuration.nix hosts/thinkpad-p14s/hardware.nix
```

5. Install:
```bash
sudo nixos-install --flake /mnt/home/dotfiles-new#thinkpad-p14s
```

#### Option B: Migrate from Existing Arch Linux

**Warning**: This replaces your current Arch Linux installation with NixOS. Backup your data first!

1. Install NixOS alongside or replace Arch Linux
2. Follow Option A steps above

#### Daily Usage

```bash
# Rebuild system configuration
sudo nixos-rebuild switch --flake ~/dotfiles-new#thinkpad-p14s

# Test configuration without activating
sudo nixos-rebuild test --flake ~/dotfiles-new#thinkpad-p14s

# Build and activate on next boot
sudo nixos-rebuild boot --flake ~/dotfiles-new#thinkpad-p14s

# Update home-manager only (faster)
home-manager switch --flake ~/dotfiles-new#susiyaki@thinkpad-p14s

# Or use convenient aliases (defined in fish config):
rebuild          # = nixos-rebuild switch
rebuild-test     # = nixos-rebuild test
rebuild-boot     # = nixos-rebuild boot
hm-switch        # = home-manager switch
```

## What's Managed

### Common (Both macOS and Linux)
- **Editors**: Neovim
- **Shell**: Fish with Starship prompt
- **Terminal**: Alacritty (OS-specific configs)
- **Multiplexer**: Tmux
- **Version Control**: Git with gh CLI
- **Development**: Node.js 22, Python 3.12, Ruby 3.3, Go, Rust, Deno
- **Version Manager**: mise (for per-project runtimes)
- **CLI Tools**: bat, eza, ripgrep, fd, fzf, zoxide, lazygit, lazydocker, jq
- **Cloud**: AWS CLI v2

### macOS-Specific
- **Window Manager**: Aerospace (tiling)
- **Status Bar**: SketchyBar
- **Keyboard**: Karabiner-Elements
- **System Settings**: Dock, Finder, Keyboard
- **GUI Apps**: Chrome, Slack, Discord, Spotify, 1Password (via Homebrew)
- **Development**: Android Studio, Docker Desktop

### Linux-Specific (ThinkPad P14s)
- **Window Manager**: Sway (Wayland compositor)
- **Status Bar**: Waybar
- **Notifications**: swaync (Sway Notification Center)
- **Display Management**: Kanshi (autorandr for Wayland)
- **Input Method**: Fcitx5 with Mozc (Japanese input)
- **Power Management**: TLP (battery optimization)
- **Audio**: PipeWire with PulseAudio support
- **Bluetooth**: Blueman
- **Launcher**: wofi / rofi-wayland
- **File Manager**: Thunar with plugins
- **GUI Apps**: Firefox, Discord, DBeaver, Postman
- **Media**: Celluloid, MPV, imv (image viewer)
- **Utilities**: brightnessctl, pavucontrol, btop, nvtop
- **Theme**: Adwaita Dark (GTK/Qt unified)

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

## Key Features

### ThinkPad P14s Optimizations
- ⚡ **AMD optimized**: Native amdgpu drivers with Vulkan/ROCm support
- 🔋 **Battery management**: TLP with 75-80% charge thresholds
- 💾 **Btrfs**: Zstd compression, monthly scrubbing, SSD optimization
- 🔄 **Zram**: 50% memory compression for better performance
- 🌐 **Wayland native**: All apps run natively on Wayland
- 🎨 **Unified theme**: Adwaita Dark across GTK/Qt applications
- 🇯🇵 **Japanese input**: Fcitx5 + Mozc with CJK fonts

### Cross-Platform Benefits
- 📦 **Declarative**: All packages and configs defined in code
- 🔄 **Atomic updates**: Rollback to any previous generation
- 🎯 **Single repo**: Both macOS and Linux from one source
- 🚀 **Reproducible**: Same config = same system
- 🔧 **Version controlled**: All changes tracked in Git

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

## Resources

- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)

## License

MIT
