# Nix Setup Guide

## Quick Start (macOS)

### 1. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**After installation, restart your terminal.**

### 2. Build and Apply Configuration

```bash
# Run the setup script
/tmp/setup-nix-darwin.sh

# If successful, apply the configuration
./result/sw/bin/darwin-rebuild switch --flake /Users/laeno/dotfiles-new#m1-mac
```

### 3. Verify Installation

```bash
/tmp/verify-nix-setup.sh
```

## What Gets Installed

### System Packages (via Nix)
- Development: neovim, lazygit, lazydocker, mise
- Runtimes: nodejs, python, ruby, go, rust, deno
- CLI tools: bat, eza, ripgrep, fd, fzf, jq, zoxide, starship, gh, htop, wget, act, awscli2

### Applications (via Homebrew Casks)
- Terminal: alacritty
- Browsers: google-chrome
- Communication: slack, discord
- Utilities: 1password, 1password-cli, karabiner-elements
- Entertainment: spotify
- Development: docker, android-studio, android-platform-tools
- Cloud: google-cloud-sdk, ngrok, session-manager-plugin
- Audio: blackhole-16ch
- Fonts: font-hack-nerd-font

### Window Management
- aerospace (tiling window manager)
- sketchybar (status bar)

## Configuration Files Managed

All files in `config/` are symlinked to `~/.config/`:
- aerospace
- alacritty
- fish
- karabiner
- nvim
- sketchybar
- tmux

## Rollback

### Rollback to Previous Generation
```bash
darwin-rebuild rollback
```

### List All Generations
```bash
darwin-rebuild --list-generations
```

### Switch to Specific Generation
```bash
darwin-rebuild --switch-generation <number>
```

## Complete Uninstall

If you want to completely remove Nix:

```bash
# 1. Uninstall nix-darwin and Nix
/nix/nix-installer uninstall

# 2. Remove Nix configuration
rm -rf ~/.config/nix
rm -rf ~/.nix-*

# 3. Your Homebrew and existing configs remain untouched
```

## Updating Configuration

After modifying files in `dotfiles-new/`:

```bash
cd ~/dotfiles-new
darwin-rebuild switch --flake .#m1-mac
```

## Troubleshooting

### "command not found: nix"
Restart your terminal or run:
```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### Build Errors
Check the error message and ensure:
- `flake.nix` syntax is correct
- All referenced files exist
- No typos in package names

### Config Files Not Updating
Home Manager manages config files. After changes:
```bash
home-manager switch --flake ~/dotfiles-new#laeno@m1-mac
```

Or rebuild everything:
```bash
darwin-rebuild switch --flake ~/dotfiles-new#m1-mac
```

## Directory Structure

```
dotfiles-new/
├── flake.nix              # Main entry point
├── hosts/
│   ├── m1-mac/           # Machine-specific config
│   └── thinkpad-p14s/    # Linux machine config
├── home/
│   ├── common.nix        # Shared user config
│   ├── darwin.nix        # macOS user config
│   └── archlinux.nix     # Linux user config
├── modules/
│   ├── common/           # Shared modules
│   ├── darwin/           # macOS modules (aerospace, sketchybar)
│   └── archlinux/        # Linux modules (sway, waybar)
└── config/               # Actual config files
    ├── aerospace/
    ├── alacritty/
    ├── fish/
    ├── karabiner/
    ├── nvim/
    ├── sketchybar/
    ├── sway/
    ├── tmux/
    └── waybar/
```

## Safety Notes

✅ **Safe Operations:**
- Nixがインストールするのは `/nix/` ディレクトリのみ
- 既存のHomebrewインストールは影響を受けません
- 既存の `~/.config/` ファイルは上書きされません（symlink作成時のみ確認が必要）
- いつでも前の世代にロールバック可能

⚠️ **Caution:**
- 初回適用時、既存のconfig fileがある場合は上書きの確認が出ます
- Homebrewとの重複パッケージは、PATHの順序で優先度が決まります

## For Other Machines

新しいdarwinマシンで使う場合:

1. `hosts/<machine-name>/default.nix` を作成
2. ユーザー名とホームディレクトリを設定
3. `flake.nix` に新しいマシンを追加
4. `darwin-rebuild switch --flake .#<machine-name>` で適用
