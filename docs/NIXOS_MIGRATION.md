# Arch Linux から NixOS への移行手順

ThinkPad P14s Gen 5 AMD を Arch Linux から NixOS に移行する詳細な手順書。

**最終更新**: 2026-01-20

---

## 目次

1. [所要時間](#所要時間)
2. [移行前の準備](#移行前の準備)
3. [方法A: デュアルブート方式（推奨）](#方法a-デュアルブート方式推奨)
4. [方法B: クリーンインストール方式](#方法b-クリーンインストール方式)
5. [インストール後の設定](#インストール後の設定)
6. [トラブルシューティング](#トラブルシューティング)

---

## 所要時間

### デュアルブート方式（推奨）

| ステップ | 所要時間 |
|---------|---------|
| パーティション縮小 | 1〜2時間 |
| NixOS ISOの準備 | 15〜20分 |
| NixOSインストール | 40分〜1時間 |
| 起動とデータ復元 | 40〜50分 |
| **合計** | **約3〜4時間** |

### クリーンインストール方式

| ステップ | 所要時間 |
|---------|---------|
| NixOS ISOの準備 | 15〜20分 |
| NixOSインストール | 40分〜1時間 |
| 起動とデータ復元 | 40〜50分 |
| **合計** | **約2〜3時間** |

**注意**: ダウンロード速度やシステムスペックによって変動します。

---

## 移行前の準備

### 1. バックアップ（完了済み ✅）

- ✅ 外付けドライブに39GBのデータをバックアップ済み
- ✅ バックアップ場所: `/mnt/backup/home-susiyaki/`
- ✅ dotfilesはGitHubにプッシュ済み

### 2. 現在のシステム情報

**ハードウェア**:
- CPU: AMD Ryzen 7 PRO 7840U
- GPU: Radeon 780M Graphics
- ストレージ: NVMe 476.9GB (SKHynix_HFS512GEJ9X162N)
- パーティション構成:
  - `/dev/nvme0n1p1`: 512MB (EFI)
  - `/dev/nvme0n1p2`: 476.4GB (Btrfs)

**現在のパーティション使用状況**:
- `/`: 212GB使用 / 263GB空き（45%使用）
- `/home`: ルートパーティションと同じ

### 3. 必要なもの

- [ ] NixOS ISOファイル（24.11以降）
- [ ] 8GB以上のUSBメモリ
- [ ] 外付けドライブ（バックアップ用、既に接続済み）
- [ ] 安定したインターネット接続

---

## 方法A: デュアルブート方式（推奨）

**メリット**:
- ✅ Arch Linuxが動作したまま移行可能
- ✅ 問題があればArchに戻れる
- ✅ 作業への影響を最小限に
- ✅ NixOSの動作確認後にArchを削除

**デメリット**:
- ❌ ディスク容量を多く消費（一時的）
- ❌ パーティション操作が必要

### ステップ1: パーティションの縮小（Arch Linuxから）

現在の使用量（212GB）+ 余裕（50GB）= 約270GBにBtrfsパーティションを縮小し、残りをNixOS用に確保します。

```bash
# 1. 現在のBtrfsの使用状況を確認
sudo btrfs filesystem usage /

# 2. Btrfsのデータを圧縮（任意だが推奨）
sudo btrfs filesystem defragment -r -v -czstd /

# 3. GPartedをインストール
sudo pacman -S gparted

# 4. GPartedを起動してパーティションを縮小
sudo gparted

# GUI操作:
# - /dev/nvme0n1p2 を右クリック → Resize/Move
# - 新しいサイズ: 280GB（現在の使用量+余裕）
# - 空き領域: 約196GB（NixOS用）
# - Apply
```

**注意**: パーティション操作は慎重に。バックアップがあることを確認してから実行してください。

### ステップ2: NixOS ISOの準備

```bash
# Arch Linuxで実行
cd ~/Downloads
wget https://channels.nixos.org/nixos-24.11/latest-nixos-minimal-x86_64-linux.iso

# USBメモリのデバイス名を確認（例: /dev/sdb）
lsblk

# ISOをUSBに書き込み（WARNING: USBメモリの全データが消去されます）
sudo dd if=nixos-24.11-*.iso of=/dev/sdX bs=4M status=progress oflag=sync

# 完了後
sudo sync
```

### ステップ3: NixOS ISOから起動

1. USBメモリを挿入
2. 再起動して、BIOS/UEFIブート順序でUSBを最優先に設定（F12キー）
3. NixOSライブ環境で起動

### ステップ4: NixOSのインストール

```bash
# =====================================
# パーティション設定
# =====================================

# 空き領域に新しいパーティションを作成
sudo cfdisk /dev/nvme0n1

# GUI操作:
# - Free spaceを選択
# - [New] → パーティションサイズ: 残り全部
# - [Type] → Linux filesystem
# - [Write] → yes
# - [Quit]

# パーティション番号を確認（おそらく /dev/nvme0n1p3）
lsblk

# 新しいパーティションをBtrfsでフォーマット
sudo mkfs.btrfs -L nixos /dev/nvme0n1p3

# マウント
sudo mount /dev/nvme0n1p3 /mnt

# Btrfsサブボリュームを作成
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix

# アンマウント
sudo umount /mnt

# 正しくマウント
sudo mount -o subvol=@,compress=zstd,noatime /dev/nvme0n1p3 /mnt
sudo mkdir -p /mnt/{home,nix,boot}
sudo mount -o subvol=@home,compress=zstd,noatime /dev/nvme0n1p3 /mnt/home
sudo mount -o subvol=@nix,compress=zstd,noatime /dev/nvme0n1p3 /mnt/nix
sudo mount /dev/nvme0n1p1 /mnt/boot

# =====================================
# ハードウェア設定の生成
# =====================================
sudo nixos-generate-config --root /mnt

# =====================================
# dotfilesのクローン
# =====================================
nix-shell -p git

# GitHub SSHキーがない場合はHTTPSでクローン
git clone https://github.com/susiyaki/dotfiles.git /mnt/home/susiyaki/dotfiles

# =====================================
# hardware.nixの更新
# =====================================
# 生成されたUUIDを確認
cat /mnt/etc/nixos/hardware-configuration.nix | grep uuid

# dotfilesのhardware.nixを更新
# UUIDを新しいパーティション（/dev/nvme0n1p3）のものに変更
nano /mnt/home/susiyaki/dotfiles/hosts/thinkpad-p14s/hardware.nix

# 変更箇所:
# fileSystems."/".device = "/dev/disk/by-uuid/<新しいUUID>";
# fileSystems."/home".device = "/dev/disk/by-uuid/<新しいUUID>";
# fileSystems."/nix".device = "/dev/disk/by-uuid/<新しいUUID>";

# =====================================
# NixOSのインストール
# =====================================
sudo nixos-install --flake /mnt/home/susiyaki/dotfiles#thinkpad-p14s

# rootパスワードを設定（プロンプトが表示されます）

# =====================================
# 再起動
# =====================================
sudo reboot
```

### ステップ5: ブート設定

再起動時にGRUBブートメニューが表示されます:
- **NixOS**: 新しくインストールしたNixOS
- **Arch Linux**: 既存のArch Linux

両方動作することを確認してください。

### ステップ6: NixOSの動作確認

NixOSで起動後、以下を確認:

```bash
# ネットワーク接続
ping google.com

# サウンド
pavucontrol

# 日本語入力（Fcitx5 + Mozc）
# Sway起動後にテスト

# ディスプレイ
# Sway起動後にマルチディスプレイをテスト

# Bluetooth
bluetoothctl
```

### ステップ7: データの復元

```bash
# 外付けドライブをマウント
sudo mkdir -p /mnt/backup
sudo mount /dev/sda1 /mnt/backup

# ホームディレクトリにデータを復元
sudo rsync -avhP --exclude='dotfiles' \
  /mnt/backup/home-susiyaki/ ~/

# 権限を修正
sudo chown -R susiyaki:users ~/

# アンマウント
sudo umount /mnt/backup
```

### ステップ8: NixOSで1週間程度使用

実際の業務でNixOSを使用し、問題がないか確認します。

**確認項目**:
- [ ] 日常業務が問題なく行える
- [ ] 全てのアプリケーションが動作する
- [ ] ハードウェア（サウンド、Bluetooth、ディスプレイ）が正常
- [ ] パフォーマンスに問題がない

### ステップ9: Arch Linuxパーティションの削除（オプション）

NixOSが安定して動作することを確認したら、Arch Linuxパーティションを削除してNixOS用の領域を拡張できます。

```bash
# NixOSから実行

# 1. GPartedをインストール
nix-shell -p gparted

# 2. GPartedを起動
sudo gparted

# GUI操作:
# - /dev/nvme0n1p2 (Arch Linux) を右クリック → Delete
# - /dev/nvme0n1p3 (NixOS) を右クリック → Resize/Move
# - 新しいサイズ: 残り全部
# - Apply

# 3. Btrfsファイルシステムを拡張
sudo btrfs filesystem resize max /

# 4. 確認
df -h
```

---

## 方法B: クリーンインストール方式

**メリット**:
- ✅ クリーンな状態でインストール
- ✅ パーティション操作がシンプル
- ✅ ディスク容量を節約

**デメリット**:
- ❌ Arch Linuxが完全に削除される
- ❌ 失敗時にArchに戻れない
- ❌ バックアップからの復元が必須

### ステップ1: NixOS ISOの準備

方法Aのステップ2と同じ。

### ステップ2: NixOS ISOから起動

方法Aのステップ3と同じ。

### ステップ3: NixOSのインストール

```bash
# =====================================
# パーティション設定（既存を完全削除）
# =====================================

# 既存のルートパーティションをBtrfsでフォーマット
sudo mkfs.btrfs -f /dev/nvme0n1p2

# マウント
sudo mount /dev/nvme0n1p2 /mnt

# Btrfsサブボリュームを作成
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix

# アンマウント
sudo umount /mnt

# 正しくマウント
sudo mount -o subvol=@,compress=zstd,noatime /dev/nvme0n1p2 /mnt
sudo mkdir -p /mnt/{home,nix,boot}
sudo mount -o subvol=@home,compress=zstd,noatime /dev/nvme0n1p2 /mnt/home
sudo mount -o subvol=@nix,compress=zstd,noatime /dev/nvme0n1p2 /mnt/nix
sudo mount /dev/nvme0n1p1 /mnt/boot

# =====================================
# ハードウェア設定の生成
# =====================================
sudo nixos-generate-config --root /mnt

# =====================================
# dotfilesのクローン
# =====================================
nix-shell -p git
git clone https://github.com/susiyaki/dotfiles.git /mnt/home/susiyaki/dotfiles

# =====================================
# hardware.nixの更新
# =====================================
# 生成されたUUIDを確認
cat /mnt/etc/nixos/hardware-configuration.nix | grep uuid

# dotfilesのhardware.nixを更新
nano /mnt/home/susiyaki/dotfiles/hosts/thinkpad-p14s/hardware.nix

# 変更箇所（全て同じUUID）:
# fileSystems."/".device = "/dev/disk/by-uuid/<新しいUUID>";
# fileSystems."/home".device = "/dev/disk/by-uuid/<新しいUUID>";
# fileSystems."/nix".device = "/dev/disk/by-uuid/<新しいUUID>";

# =====================================
# NixOSのインストール
# =====================================
sudo nixos-install --flake /mnt/home/susiyaki/dotfiles#thinkpad-p14s

# rootパスワードを設定

# =====================================
# 再起動
# =====================================
sudo reboot
```

### ステップ4: データの復元

方法Aのステップ7と同じ。

---

## インストール後の設定

### 1. システムの更新

```bash
# 最新の状態に更新
sudo nixos-rebuild switch --flake ~/dotfiles#thinkpad-p14s
```

### 2. home/linux.nixの調整（NixOS移行後）

```bash
cd ~/dotfiles

# speak-to-aiモジュールの参照を変更
nano home/linux.nix

# 変更前:
# ../modules/linux/speak-to-ai/archlinux.nix

# 変更後:
# ../modules/linux/speak-to-ai  # default.nixが読み込まれる（コメントアウト済み）
```

### 3. SSH鍵の設定

```bash
# SSH鍵がバックアップから復元されているか確認
ls -la ~/.ssh/

# SSH agentの設定（keychainが自動起動）
# home/linux.nixで既に設定済み
```

### 4. 1Passwordのインストール

```bash
# 1PasswordはNixOSでもインストール済み（hosts/thinkpad-p14s/default.nix）
# 初回起動時にログイン
```

### 5. ブラウザの設定

```bash
# Firefoxを起動して、Syncでログイン
# または、バックアップから ~/.mozilla を復元済み
```

---

## トラブルシューティング

### ブートできない場合

```bash
# NixOS ISOから起動
# 既存のNixOSパーティションをマウント
sudo mount -o subvol=@ /dev/nvme0n1p3 /mnt  # デュアルブートの場合
# または
sudo mount -o subvol=@ /dev/nvme0n1p2 /mnt  # クリーンインストールの場合

sudo mount -o subvol=@home /dev/nvme0n1pX /mnt/home
sudo mount -o subvol=@nix /dev/nvme0n1pX /mnt/nix
sudo mount /dev/nvme0n1p1 /mnt/boot

# 再インストール
sudo nixos-install --flake /mnt/home/susiyaki/dotfiles#thinkpad-p14s
```

### ハードウェアが認識されない場合

```bash
# hardware.nixを再生成
sudo nixos-generate-config --root /

# 生成された /etc/nixos/hardware-configuration.nix を参考に
# ~/dotfiles/hosts/thinkpad-p14s/hardware.nix を更新
```

### デュアルブート時にArchが起動しない場合

```bash
# NixOSから実行
sudo nixos-rebuild switch --flake ~/dotfiles#thinkpad-p14s

# GRUBが自動的にArchを検出します
```

---

## 参考情報

### NixOS公式ドキュメント
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

### Btrfsサブボリューム構成の利点
- `@`: ルートファイルシステム（OSの復元が容易）
- `@home`: ホームディレクトリ（ユーザーデータを保護）
- `@nix`: Nixストア（システムとユーザーデータを分離）

### 重要なファイル
- `flake.nix`: NixOS設定のエントリーポイント
- `hosts/thinkpad-p14s/default.nix`: システム設定
- `hosts/thinkpad-p14s/hardware.nix`: ハードウェア設定（**UUIDを更新必須**）
- `home/linux.nix`: ユーザー環境設定

---

## チェックリスト

### 移行前
- [x] ホームディレクトリのバックアップ（39GB）
- [x] dotfilesのGitHubプッシュ
- [x] hardware.nixのBtrfsサブボリューム対応
- [x] システム設定のNixOS化（WoWLAN、uinput）
- [ ] NixOS ISOのダウンロード
- [ ] USBメモリの準備

### インストール中
- [ ] パーティション作成/縮小（方法による）
- [ ] NixOSインストール成功
- [ ] hardware.nixのUUID更新
- [ ] 初回起動成功

### インストール後
- [ ] ネットワーク接続OK
- [ ] サウンドOK
- [ ] 日本語入力OK
- [ ] ディスプレイ設定OK
- [ ] BluetoothOK
- [ ] データ復元完了
- [ ] 1Passwordログイン
- [ ] ブラウザ設定復元

---

## 移行後の注意点

### 除外されたキャッシュの再構築

以下のキャッシュはバックアップから除外されているため、NixOS上で自動的に再構築されます：

- npmキャッシュ（`~/.npm`）
- Gradleキャッシュ（`~/.gradle`）
- miseランタイム（`~/.local/share/mise`）
- pnpmキャッシュ（`~/.local/share/pnpm`）
- Rustツールチェイン（`~/.local/share/rustup`）
- Goモジュール（`~/.local/share/go`）

### Arch Linux固有のパッケージ

以下はArch Linux（AUR）で手動インストールしていたもので、NixOSでは対応が必要：

- `speak-to-ai`: コメントアウト済み（modules/linux/speak-to-ai/default.nix）
- その他AURパッケージ: 必要に応じてNixパッケージを探すか、カスタムビルド

---

**作成日**: 2026-01-20
**対象マシン**: ThinkPad P14s Gen 5 AMD
**Arch Linux バージョン**: Rolling
**NixOS バージョン**: 24.11以降
