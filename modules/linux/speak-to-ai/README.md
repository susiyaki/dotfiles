# speak-to-ai module

オフライン音声認識デーモン [speak-to-ai](https://github.com/speak-to-ai/speak-to-ai) の設定。

## ファイル構成

- **default.nix**: NixOS用の設定（コメントアウト済み）
- **archlinux.nix**: Arch Linux用の設定（`/usr/bin/speak-to-ai`を使用）

## 使い分け

### Arch Linuxで使用する場合（現在）

`home/linux.nix`で以下のようにimport:
```nix
imports = [
  ../modules/linux/speak-to-ai/archlinux.nix  # Arch Linux用
];
```

### NixOSで使用する場合（移行後）

1. speak-to-aiをビルド・インストール
2. `home/linux.nix`で以下のようにimport:
```nix
imports = [
  ../modules/linux/speak-to-ai  # default.nixが読み込まれる
];
```

## NixOSでの対応方法

speak-to-aiはnixpkgsに存在しないため、以下のいずれかが必要：

1. **カスタムパッケージを作成**
2. **手動ビルド**してホームディレクトリ（`~/.local/bin/`）に配置
3. **このモジュールを無効化**（移行後に検討）
