{ lib, ... }:

{
  # Local-only settings for macOS (git-ignored if you add to .gitignore)
  home.username = "laeno";
  home.homeDirectory = "/Users/laeno";

  # Git identity override (example)
  # programs.git.settings.user.email = "you@example.com";

  # Local SSH config (optional)
  # home.file.".ssh/config".source = ./secrets/ssh-config;
}
