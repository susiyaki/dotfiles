# AURパッケージリスト（Arch Linux）

NixOSへの移行時に確認すべきAURパッケージのリスト。

**最終更新**: 2026-01-20

---

## 必須パッケージ（NixOSでも必要）

### パスワード管理
- ✅ **1password** (8.11.20-39) - NixOSで利用可能（hosts/thinkpad-p14s/default.nix:96で設定済み）
- ✅ **1password-cli** (2.32.0-2) - NixOSで利用可能（パッケージ名: `_1password-gui`, `_1password`）

### 日本語入力
- ✅ **fcitx5-cskk-git** (1.2.0.r25.g7ea5133-1) - NixOSで利用可能（`fcitx5-cskk`）
- ⚠️ **cskk-git** (v3.2.0.r8.f64da6b-1) - fcitx5-cskkの依存、自動インストール

### フォント
- ✅ **ttf-hackgen** (2.10.0-1) - 手動ダウンロードまたはNix overlay作成が必要
- ✅ **ttf-symbola** (14.00-2) - NixOSでは`symbola`パッケージ

### ブラウザ
- ✅ **google-chrome** (144.0.7559.59-1) - NixOSで利用可能（`google-chrome`）

### コミュニケーション
- ✅ **slack-desktop** (4.46.104-1) - NixOSで利用可能（`slack`）

### 開発ツール
- ✅ **claude-code** (2.0.57-1) - NixOSで利用可能（`claude-code`）
- ✅ **watchman-bin** (2025.11.24.00-1) - **React Native開発で必要**、NixOSで利用可能（`watchman`）
- ✅ **termius** (9.34.4-1) - NixOSで利用可能（`termius`）

### Wayland/Sway関連
- ✅ **clipman** (1.6.5-1) - NixOSで利用可能（`clipman`）
- ✅ **wdisplays** (1.1.3-1) - NixOSで利用可能（`wdisplays`）
- ✅ **wlogout** (1.2.2-0) - NixOSで利用可能（`wlogout`）

---

## Android開発関連（必要に応じて）

- ⚠️ **android-platform** (36_r02-1)
- ⚠️ **android-sdk** (26.1.1-2)
- ⚠️ **android-sdk-build-tools** (r36.1-2)
- ⚠️ **android-sdk-platform-tools** (36.0.0-1)

**NixOSでの対応**:
```nix
# home/linux.nixまたはhosts/thinkpad-p14s/default.nix
environment.systemPackages = with pkgs; [
  android-tools
  # Android SDK全体が必要な場合:
  # android-studio
];

# 環境変数はhome/linux.nixで既に設定済み
home.sessionVariables = {
  ANDROID_HOME = "$HOME/Android/Sdk";
  ANDROID_SDK_ROOT = "$HOME/Android/Sdk";
};
```

**確認**: Android開発を現在行っていますか？
- [ ] はい → NixOSでも設定が必要
- [ ] いいえ → NixOS移行時にスキップ可能

---

## ハードウェアドライバー

### DisplayLink（外部ディスプレイアダプター）
- ⚠️ **displaylink** (6.2-1)
- ⚠️ **evdi-dkms** (1.14.11-2) - DisplayLinkの依存

**確認**: DisplayLinkアダプターを使用していますか？
- [ ] はい → NixOSでDisplayLinkドライバーの設定が必要
- [ ] いいえ → NixOS移行時に不要

**NixOSでの対応**:
```nix
# hosts/thinkpad-p14s/default.nix
services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
```

### DDC/CI（モニター制御）
- ⚠️ **ddcci-driver-linux-dkms** (0.4.5-1) - モニターの明るさ調整用

**確認**: DDC/CIでモニターを制御していますか？
- [ ] はい → NixOSで設定が必要
- [ ] いいえ → brightnessctlで代替可能

### Nintendo Switchコントローラー
- ❓ **hid-nintendo-dkms** (3.2-2)

**確認**: Nintendo Switchのコントローラーを使用していますか？
- [ ] はい → NixOSでカーネルモジュールの設定が必要
- [ ] いいえ → NixOS移行時に不要

---

## 使用していない可能性が高いパッケージ

### 重複・置き換え済み
- ❌ **redshift-wayland-git** (1.12.r25.g7da875d-1)
  - **理由**: `gammastep`で置き換え済み（hosts/thinkpad-p14s/default.nix:63）
  - **NixOS**: 不要（既にgammastepを使用）

### 古いバージョンの依存
- ❓ **wlroots0.16** (0.16.2-2)
  - **確認**: 特定のアプリケーションの依存かもしれません
  - **NixOS**: Swayが自動的に適切なバージョンを使用

### テストツール
- ❓ **xwayland-run** (0.0.4-4)
  - **用途**: XWaylandアプリケーションのテスト用？
  - **NixOS**: 必要に応じて`xwayland-run`パッケージをインストール

### 開発依存（ビルド時のみ）
- ❓ **ccache-git** (4.12.r102.8558d0f8-1)
  - **用途**: C/C++コンパイルキャッシュ
  - **確認**: 現在C/C++開発をしていますか？
  - **NixOS**: 必要に応じて`ccache`パッケージをインストール

- ❓ **haskell-data-array-byte** (0.1.0.1-80)
- ❓ **haskell-semigroups** (0.20-1)
  - **用途**: Haskellライブラリ（何かのビルド依存？）
  - **NixOS**: 通常は不要

### デバッグシンボルパッケージ（全て不要）
以下は全てデバッグ用で、通常の使用では不要です：
- ❌ *-debug パッケージ（17個）
  - 例: `1password-cli-debug`, `ccache-git-debug`, `cskk-git-debug`など
  - **NixOS**: 不要（デバッグ時のみ必要）

---

## Arch Linux専用（NixOSでは不要）

- ❌ **yay** (12.5.7-1) - AURヘルパー（Arch専用）

---

## NixOS移行時のチェックリスト

### ✅ 設定済み（NixOS設定に追加完了）
- [x] 1Password
- [x] Google Chrome
- [x] Slack
- [x] claude-code
- [x] fcitx5-cskk（日本語入力）
- [x] ttf-hackgen（フォント - カスタムパッケージ作成済み）
- [x] clipman, wdisplays, wlogout（Wayland/Sway）
- [x] watchman（React Native開発で使用中）
- [x] termius（SSH/SFTPクライアント）
- [x] android-tools（adbコマンド）
- [x] DisplayLink（Kernel 6.6 LTS + evdi設定済み）

### ❌ 削除対象（不要と確認済み）
- [x] VSCode → 不要
- [x] Android SDK全体 → adbのみで十分
- [x] ddcci-driver → 使用していない
- [x] hid-nintendo → 使用していない
- [x] redshift-wayland-git → gammastepに置き換え済み
- [x] ccache → 使用していない
- [x] haskellパッケージ → 使用していない
- [x] *-debug パッケージ（全17個） → デバッグ用で不要
- [x] yay → Arch専用AURヘルパー

---

## speak-to-aiについて

- ⚠️ **speak-to-ai** (1.6.0-1)
  - **状態**: AUR専用パッケージ
  - **NixOS**: nixpkgsに存在しない
  - **対応**: `modules/linux/speak-to-ai/default.nix`でコメントアウト済み
  - **移行後**: 手動ビルドまたはカスタムNixパッケージ作成が必要

---

**次のアクション**:
1. 上記の「確認が必要」項目をチェック
2. 不要なパッケージを特定
3. NixOS移行時に必要なパッケージリストを確定
