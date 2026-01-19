# NixOS移行後の追加セットアップ

NixOSで自動インストールされないパッケージや追加設定が必要なもの。

**最終更新**: 2026-01-20

---

## フォント

### ttf-hackgen

HackGenフォントはnixpkgsに存在しないため、手動インストールが必要です。

**方法1: 手動ダウンロード**

```bash
# HackGenフォントをダウンロード
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/yuru7/HackGen/releases/download/v2.10.0/HackGen_NF_v2.10.0.zip
unzip HackGen_NF_v2.10.0.zip
rm HackGen_NF_v2.10.0.zip

# フォントキャッシュを更新
fc-cache -fv
```

**方法2: Nixカスタムパッケージ作成（推奨）**

```nix
# ~/dotfiles/pkgs/ttf-hackgen/default.nix を作成
{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "ttf-hackgen";
  version = "2.10.0";

  src = fetchzip {
    url = "https://github.com/yuru7/HackGen/releases/download/v${version}/HackGen_NF_v${version}.zip";
    sha256 = ""; # nix-prefetch-url で取得
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp *.ttf $out/share/fonts/truetype/
  '';
}
```

```nix
# home/linux.nix に追加
home.packages = with pkgs; [
  # ... 既存のパッケージ
  (callPackage ../pkgs/ttf-hackgen { })
];
```

---

## 1Password

1Password設定は **既に完了しています** ✅

**hosts/thinkpad-p14s/default.nix**:
```nix
programs._1password.enable = true;
programs._1password-gui = {
  enable = true;
  polkitPolicyOwners = [ "susiyaki" ];
};
```

NixOSインストール後、初回起動時に1Passwordにログインするだけで使用できます。

---

## speak-to-ai（オプション）

speak-to-aiはnixpkgsに存在しないため、以下のいずれかが必要：

### 方法1: 無効化（推奨）

NixOS移行直後は無効化し、後で必要に応じて対応。

```nix
# home/linux.nix
imports = [
  ./common.nix
  ../modules/linux/sway
  ../modules/linux/waybar
  ../modules/linux/xremap
  ../modules/linux/wofi
  ../modules/linux/wireplumber-watchdog
  # ../modules/linux/speak-to-ai/archlinux.nix  # コメントアウト
];
```

### 方法2: 手動ビルド

```bash
# ソースからビルドしてインストール
git clone https://github.com/speak-to-ai/speak-to-ai
cd speak-to-ai
# ビルド手順に従う
# バイナリを ~/.local/bin/ に配置
```

```nix
# modules/linux/speak-to-ai/default.nix のコメントを解除
# ExecStart = "%h/.local/bin/speak-to-ai -config %h/.config/speak-to-ai/config.yaml";
```

### 方法3: Nixカスタムパッケージ作成

speak-to-aiのNixパッケージを作成（高度）。

---

## DisplayLink

DisplayLink設定は **既に完了しています** ✅

### 設定内容

**hosts/thinkpad-p14s/default.nix**:
- ✅ Kernel 6.6 LTS を使用（DisplayLinkの安定性のため）
- ✅ videoDrivers に displaylink と modesetting を設定

**hosts/thinkpad-p14s/hardware.nix**:
- ✅ evdi カーネルモジュールを initrd と extraModulePackages に追加

### カーネルバージョンについて

DisplayLinkの evdi モジュールは新しいカーネルとの互換性問題があります：
- ❌ **Kernel 6.12+**: [ビルドエラー](https://github.com/NixOS/nixpkgs/issues/437311)
- ✅ **Kernel 6.6 LTS**: 安定動作（設定済み）

参考: [NixOS DisplayLink Wiki](https://wiki.nixos.org/wiki/Displaylink)

### トラブルシューティング

もしDisplayLinkが動作しない場合：

```bash
# evdiモジュールが読み込まれているか確認
lsmod | grep evdi

# 手動でモジュールを読み込む
sudo modprobe evdi

# カーネルログを確認
journalctl -k | grep -i displaylink
```

---

## Android開発（React Native）

Android SDKは不要ですが、adbコマンドは必要です。

**既に設定済み**:
```nix
# home/linux.nix
home.packages = with pkgs; [
  android-tools  # adb, fastboot などが含まれる
];
```

**動作確認**:
```bash
# デバイスを接続してテスト
adb devices
```

---

## Haskellパッケージ（不要の可能性が高い）

以下のパッケージがインストールされていましたが、用途不明：

- haskell-data-array-byte
- haskell-semigroups

何かのビルド時依存だった可能性が高く、NixOS移行後は不要と思われます。

必要になった場合、NixのHaskellインフラで管理できます。

---

## チェックリスト

### ✅ 設定済み
- [x] HackGenフォントのカスタムパッケージ作成
- [x] 1Passwordの設定
- [x] android-toolsの設定（adbコマンド）
- [x] DisplayLinkの設定（Kernel 6.6 LTS + evdi）

### NixOSインストール後の確認
- [ ] adbコマンドの動作確認: `adb devices`
- [ ] DisplayLinkモニターの接続確認
- [ ] 1Passwordへのログイン

### オプション
- [ ] speak-to-aiの対応（現在は無効化推奨）

---

## 参考

- [NixOS Fonts](https://nixos.wiki/wiki/Fonts)
- [NixOS 1Password](https://search.nixos.org/options?query=_1password)
- [Android Development on NixOS](https://nixos.wiki/wiki/Android)
