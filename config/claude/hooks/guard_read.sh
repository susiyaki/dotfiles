#!/usr/bin/env bash
set -euo pipefail

# PermissionRequest hook for Read tool.
# git-tracked files → allow automatically
# Otherwise        → fall through to normal permission prompt

stdin_json="$(cat)"

tool_name="$(echo "$stdin_json" | jq -r '.tool_name // empty')"
[[ "$tool_name" == "Read" ]] || exit 0

file_path="$(echo "$stdin_json" | jq -r '.tool_input.file_path // empty')"
[[ -n "$file_path" ]] || exit 0

# Resolve to absolute then check git tracking
if [[ -f "$file_path" ]] && git ls-files --error-unmatch "$file_path" >/dev/null 2>&1; then
  echo '{"decision":"allow"}'
fi

# Not tracked → no output → normal permission prompt
