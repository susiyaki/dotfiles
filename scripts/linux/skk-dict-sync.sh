#!/usr/bin/env bash
set -euo pipefail

skel_dict="${SKEL_DICT:-$HOME/.skkeleton}"
fcitx_dict="${FCITX_DICT:-$HOME/.local/share/fcitx5/skk/user.dict}"

mkdir -p "$(dirname "$skel_dict")" "$(dirname "$fcitx_dict")"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

skel_utf8="$tmpdir/skel.utf8"
fcitx_utf8="$tmpdir/fcitx.utf8"
merged_utf8="$tmpdir/merged.utf8"
utf8_norm="$tmpdir/user.norm.utf8"
euc_norm="$tmpdir/user.norm.eucjp"
ari_lines="$tmpdir/ari.lines"
nasi_lines="$tmpdir/nasi.lines"

to_utf8_or_empty() {
  local src="$1"
  local enc="$2"
  local dst="$3"
  if [[ -s "$src" ]]; then
    iconv -f "$enc" -t UTF-8 "$src" > "$dst"
  else
    : > "$dst"
  fi
}

extract_entries() {
  local src="$1"
  local ari_out="$2"
  local nasi_out="$3"
  awk -v ari_out="$ari_out" -v nasi_out="$nasi_out" '
    /^;; okuri-ari entries\./ { section = "ari"; next }
    /^;; okuri-nasi entries\./ { section = "nasi"; next }
    /^;;/ { next }
    NF == 0 { next }
    section == "ari" { print >> ari_out; next }
    section == "nasi" { print >> nasi_out; next }
  ' "$src"
}

to_utf8_or_empty "$skel_dict" "UTF-8" "$skel_utf8"
to_utf8_or_empty "$fcitx_dict" "EUC-JP" "$fcitx_utf8"

: > "$ari_lines"
: > "$nasi_lines"
extract_entries "$skel_utf8" "$ari_lines" "$nasi_lines"
extract_entries "$fcitx_utf8" "$ari_lines" "$nasi_lines"

if [[ ! -s "$ari_lines" && ! -s "$nasi_lines" ]]; then
  cat > "$merged_utf8" <<'EOF'
;; okuri-ari entries.
;; okuri-nasi entries.
EOF
else
  {
    echo ';; okuri-ari entries.'
    awk '!seen[$0]++' "$ari_lines"
    echo ';; okuri-nasi entries.'
    awk '!seen[$0]++' "$nasi_lines"
  } > "$merged_utf8"
fi

{
  echo ';;; -*- coding: euc-jp -*-'
  cat "$merged_utf8"
} > "$utf8_norm"

iconv -f UTF-8 -t EUC-JP "$utf8_norm" > "$euc_norm"

if [[ ! -f "$skel_dict" ]] || ! cmp -s "$utf8_norm" "$skel_dict"; then
  cp "$utf8_norm" "$skel_dict"
fi

if [[ ! -f "$fcitx_dict" ]] || ! cmp -s "$euc_norm" "$fcitx_dict"; then
  cp "$euc_norm" "$fcitx_dict"
fi
