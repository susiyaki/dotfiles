#!/bin/bash

# chezmoiのsourceDir以下を指定してtmplファイルをonepasswordにアップロードして反映する

TARGET=$1
TAGS="chezmoi"
OP_UUID=
OP_TITLE=
CHEZMOI_ROOT=$(chezmoi data | jq '.chezmoi.sourceDir' | sed -e 's/"//g;')

function check_tmpl_file() {
  if [ ! -f "$CHEZMOI_ROOT/$TARGET" ]; then
    echo "$CHEZMOI_ROOT/$TARGET is not exists."
    exit
  fi
}

function generate_op_title() {
  OP_TITLE=$(echo $TARGET | sed -e 's/encrypted_//g;s/dot_/\./g;s/executable_//g;s/readonly_//g;s/private_//g;s/create_//g;s/modify_//g;s/remove_//g;s/exact_//g;s/run_once_//g;s/run_onchange_//g;s/before//g;s/after_//g;s/\.tmpl//g;')
}

# onepasswordに保存(要ログイン)
function save_op() {
  op_json=$(op create document $CHEZMOI_ROOT/$TARGET --tags $TAGS --title $OP_TITLE)

  OP_UUID=$(echo $op_json | jq '.uuid')
}

# tmplファイルの内容をセット
function override_tmpl_file() {
  echo "{{- onepasswordDocument: "$OP_UUID" -}}" > $CHEZMOI_ROOT/$TARGET
}

generate_op_title
save_op
override_tmpl_file
