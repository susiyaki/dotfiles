function fish_mode_prompt
  switch $fish_bind_mode
    case default
      set_color ff9900
    case insert
      set_color 67efeb
    case replace_one
      set_color fc5555
    case visual
      set_color 9454c9
    case '*'
      set_color normal
  end
  echo -n (set_color -o)$USER
  set_color -b normal
end
