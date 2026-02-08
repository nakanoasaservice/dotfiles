{
  description = "Nakano's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    hostname = "nakano-mbp";
    username = "nakano";
    system = "aarch64-darwin";
    home = "Users/${username}";

    pkgs = import nixpkgs {
      inherit system;
    };

    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = system;

      users.users.${username} = {
        shell = pkgs.fish;
        home = "/Users/nakano";
      };
      
      environment.shells = [ pkgs.fish ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#nakano-mbp
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system pkgs;
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {
            home = {
              stateVersion = "26.05";
              username = username;
              homeDirectory = "/Users/nakano";

              packages = with pkgs; [
                ripgrep
                nushell
                bat
                fd
                fzf
                ghq
                zellij
                tldr
                helix
                gnupg
                jq
                ijq
              ];
            };
          };
        }
      ];
    };
  };
}
