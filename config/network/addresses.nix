let
  localPath = ./local.nix;
  defaults = {
    tailscale = {
      nas = "100.64.0.1";
      smartphone = "100.64.0.2";
      thinkpadP14s = "100.64.0.3";
    };
  };
in
if builtins.pathExists localPath then
  defaults // (import localPath)
else
  defaults
