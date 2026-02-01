{
  description = "susiyaki's dotfiles for macOS and Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs: {
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
              extraSpecialArgs = { inherit inputs; };
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
              extraSpecialArgs = { inherit inputs; };
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
      };
      "susiyaki@thinkpad-p14s" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home/linux.nix ];
      };
    };
  };
}
