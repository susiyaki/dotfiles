{
  description = "susiyaki's dotfiles for macOS and Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # macOS system management
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nix-darwin, home-manager, android-nixpkgs, ... }@inputs:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
      forAllSystems = function: nixpkgs.lib.genAttrs supportedSystems (system: function system);
      pkgsStableFor = system: import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # macOS system (nix-darwin)
      darwinConfigurations = {
        m1-mac = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/m1-mac
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.laeno = import ./home/darwin.nix;
                extraSpecialArgs = {
                  inherit inputs android-nixpkgs;
                  pkgsStable = pkgsStableFor "aarch64-darwin";
                };
              };
            }
          ];
        };
      };

      # Linux system (NixOS)
      nixosConfigurations = {
        thinkpad-p14s = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/thinkpad-p14s
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.susiyaki = import ./home/linux.nix;
                extraSpecialArgs = {
                  inherit inputs android-nixpkgs;
                  pkgsStable = pkgsStableFor "x86_64-linux";
                };
              };
            }
          ];
        };
      };

      # Standalone Home Manager (optional)
      homeConfigurations = {
        "laeno@m1-mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [ ./home/darwin.nix ];
          extraSpecialArgs = {
            inherit inputs android-nixpkgs;
            pkgsStable = pkgsStableFor "aarch64-darwin";
          };
        };
        "susiyaki@thinkpad-p14s" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home/linux.nix ];
          extraSpecialArgs = {
            inherit inputs android-nixpkgs;
            pkgsStable = pkgsStableFor "x86_64-linux";
          };
        };
      };

      # Formatter for nix fmt
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
