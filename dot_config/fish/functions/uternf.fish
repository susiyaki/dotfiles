function uternf
  set --local selected_log_groups (aws logs describe-log-groups --query "logGroups[].[logGroupName]" --output text | fzf --multi --no-preview)
  utern (echo $selected_log_groups)
end
