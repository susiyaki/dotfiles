# Arch Linux + home-manager Setup Guide

このガイドでは、Arch Linuxのまま、Nixとhome-managerを使ってdotfilesを管理する方法を説明します。

## システム要件

- Arch Linux (インストール済み)
- sudo権限
- インターネット接続

## 1. システムパッケージのインストール

Nixで管理できないシステムレベルのパッケージをpacmanでインストールします。

```bash
# ベースシステム
sudo pacman -S --needed \
  base-devel \
  git \
  curl \
  wget

# ウィンドウマネージャーとデスクトップ環境
sudo pacman -S --needed \
  sway \
  swaylock \
  swayidle \
  swaybg \
  xorg-xwayland \
  gdm \
  waybar

# オーディオ
sudo pacman -S --needed \
  pipewire \
  pipewire-alsa \
  pipewire-pulse \
  pipewire-jack \
  wireplumber \
  pavucontrol

# 日本語入力
sudo pacman -S --needed \
  fcitx5-im \
  fcitx5-mozc

# Bluetooth
sudo pacman -S --needed \
  bluez \
  bluez-utils \
  blueman

# 電源管理
sudo pacman -S --needed \
  tlp \
  tlp-rdw \
  powertop

# ネットワーク
sudo pacman -S --needed \
  networkmanager \
  network-manager-applet

# その他ユーティリティ
sudo pacman -S --needed \
  polkit \
  xdg-desktop-portal \
  xdg-desktop-portal-wlr \
  xdg-desktop-portal-gtk

# Docker (optional)
sudo pacman -S --needed \
  docker \
  docker-compose

# プリンター (optional)
sudo pacman -S --needed \
  cups \
  cups-pdf
```

## 2. システムサービスの有効化

```bash
# ディスプレイマネージャー (GDM)
sudo systemctl enable gdm
sudo systemctl start gdm

# 電源管理 (TLP)
sudo systemctl enable tlp
sudo systemctl start tlp

# Bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Docker (optional)
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# プリンター (optional)
sudo systemctl enable cups
sudo systemctl start cups
```

## 3. Fcitx5の設定

`~/.config/environment.d/fcitx5.conf` を作成：

```bash
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/fcitx5.conf << 'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF
```

## 4. Nixのインストール

公式のNix installerを使用します：

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

インストール後、シェルを再起動：

```bash
exec $SHELL
```

Nixが正しくインストールされたか確認：

```bash
nix --version
```

## 5. Nix Flakesの有効化

`~/.config/nix/nix.conf` を作成：

```bash
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
EOF
```

## 6. dotfilesのクローン

```bash
cd ~
git clone https://github.com/yourusername/dotfiles-new.git
cd dotfiles-new
```

## 7. home-managerの初回セットアップ

```bash
nix run home-manager/master -- switch --flake ~/dotfiles-new#susiyaki@thinkpad-p14s
```

## 8. 日常的な使い方

### 設定を更新

dotfilesを編集した後：

```bash
home-manager switch --flake ~/dotfiles-new#susiyaki@thinkpad-p14s

# または、エイリアス（初回セットアップ後に有効）
hm-switch
```

### パッケージを更新

```bash
cd ~/dotfiles-new
nix flake update
home-manager switch --flake .#susiyaki@thinkpad-p14s
```

### システムパッケージの更新

```bash
sudo pacman -Syu
```

### ガベージコレクション

古いNixの世代を削除：

```bash
nix-collect-garbage -d
```

## 9. ログイン設定

GDMでログインする際、Swayセッションを選択してください。

## トラブルシューティング

### Fcitx5が起動しない

```bash
# 手動起動
fcitx5 &

# 自動起動設定 (Swayの設定に追加済み)
```

### 日本語入力が効かない

環境変数が設定されているか確認：

```bash
echo $GTK_IM_MODULE  # fcitx が表示されるべき
echo $QT_IM_MODULE   # fcitx が表示されるべき
```

表示されない場合、ログアウト・ログインし直してください。

### Waybarが起動しない

Swayが起動しているか確認：

```bash
ps aux | grep sway
```

### home-managerでエラーが出る

```bash
# ビルドのみテスト（適用しない）
home-manager build --flake ~/dotfiles-new#susiyaki@thinkpad-p14s

# エラーメッセージを確認
nix flake check ~/dotfiles-new
```

## 参考リンク

- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Sway Wiki](https://github.com/swaywm/sway/wiki)
