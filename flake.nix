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

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      hostname = "nakano-mbp";
      username = "nakano";
      gitName = "Nakano as a Service";
      gitEmail = "nakanoasaservice@gmail.com";
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
      };

      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            vim
            secretive
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
            home = "/Users/${username}";
          };

          environment.shells = [ pkgs.fish ];

          system.primaryUser = username;

          fonts.packages = with pkgs; [
            udev-gothic
          ];

          system.defaults.finder = {
            AppleShowAllExtensions = true;
            ShowPathbar = true;
          };

          system.defaults.dock = {
            autohide = true;
            orientation = "bottom";
          };

          system.defaults.trackpad = {
            Clicking = true;
            TrackpadThreeFingerDrag = true;
          };

          system.defaults.NSGlobalDomain = {
            KeyRepeat = 2;
            InitialKeyRepeat = 15;
          };

          homebrew = {
            enable = true;

            casks = [
              "1password"
              "coteditor"
              "cursor"
              "google-chrome"
              "discord"
              "drawio"
              "firefox"
              "figma"
              "fork"
              "ghostty"
              "google-japanese-ime"
              "karabiner-elements"
              "notion-calendar"
              "notion"
              "orbstack"
              "raycast"
              "slack"
              "tailscale-app"
              # "thebrowsercompany-dia" # なぜかダウンロードできない
              "vlc"
              "zoom"
            ];
          };
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

            home-manager.backupFileExtension = "bak";

            home-manager.users.${username} = {

              # fish defaults this to true, but man.package is null on Darwin.
              programs.man.generateCaches = false;

              programs.fish = {
                enable = true;
                shellInit = ''
                  string match -q "$TERM_PROGRAM" cursor
                    and . (/usr/local/bin/cursor --locate-shell-integration-path fish)
                  
                  /etc/profiles/per-user/${username}/bin/mise activate fish | source
                '';

                shellAliases = {
                  vim = "fresh";
                };

                plugins = [
                  {
                    name = "fish-bd";
                    src = pkgs.fishPlugins.fish-bd.src;
                  }
                  {
                    name = "tide";
                    src = pkgs.fishPlugins.tide.src;
                  }
                ];
              };

              programs.fresh-editor = {
                enable = true;
                defaultEditor = true;
              };

              programs.gh = {
                enable = true;
                gitCredentialHelper.enable = true;
              };

              programs.git = {
                enable = true;

                ignores = [
                  "**/.claude/settings.local.json"
                ];

                signing = {
                  format = "ssh";
                  signByDefault = true;
                };

                settings = {
                  user = {
                    name = gitName;
                    email = gitEmail;
                  };

                  core.ignorecase = false;

                  diff.tool = "difftastic";

                  difftool = {
                    prompt = false;
                    difftastic.cmd = "${pkgs.difftastic}/bin/difft \"$LOCAL\" \"$REMOTE\"";
                  };

                  pager.difftool = true;

                  gpg.ssh.allowedSignersFile = "~/.gitallowedsigners";
                };
              };

              home = {
                stateVersion = "26.05";
                username = username;
                homeDirectory = "/Users/${username}";

                sessionPath = [ "$HOME/.moon/bin" ];

                sessionVariables = {
                  SSH_AUTH_SOCK = "/Users/${username}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
                };

                packages = with pkgs; [
                  ast-grep
                  bat
                  bombardier
                  difftastic
                  cmake
                  eza
                  fd
                  fzf
                  ghq
                  gnupg
                  google-cloud-sdk
                  ijq
                  jq
                  mise
                  nixd
                  nixfmt
                  nushell
                  qrencode
                  ripgrep
                  tldr
                  zellij
                ];
              };
            };
          }
        ];
      };
    };
}
