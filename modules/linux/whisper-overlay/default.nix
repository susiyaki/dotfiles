{ config, pkgs, inputs, ... }:

let
  whisper-overlay-pkg = inputs.whisper-overlay.packages.${pkgs.system}.default;
in
{
  imports = [
    inputs.whisper-overlay.homeManagerModules.default
  ];

  # Realtime STT Server Configuration
  services.realtime-stt-server = {
    enable = true;
    autoStart = true; # Start with session
    package = whisper-overlay-pkg;
    # AMD Ryzen (CPU) configuration
    # Note: CUDA is not available on AMD GPUs. 
  };

  # Whisper Overlay Client Package
  home.packages = [
    whisper-overlay-pkg
  ];

  # Ensure user is in 'input' group for evdev access (handled in system config, but good to note)
  # Users must be in 'input' group to use global hotkeys via evdev.
}
