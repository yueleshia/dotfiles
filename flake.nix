#run: home-manager switch --flake .#port
{
  description = "Multi-Host Home Manager configuration";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs.url = "nixpkgs";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, unstable, home-manager, ... }: {
    # Define one host per key in ${hosts}
    # We are off-loading most of the configuration to nickel
    #
    # Host     is a physical computer
    # Profile  is a software setup
    # External is the extra 'home' directory that exists on Android/Windows
    homeConfigurations = let
      nickel-source = builtins.path { path = ./src; }; # Copy ./src into store on nix realisation
      host          = builtins.fromJSON (builtins.readFile "${nickel-source}/gen_environment.json");

      # @NOTE: Make sure this path is valid
      dotfiles_dir  = "/home/${host.username}/dotfiles";

      home-manager-nix = derivationStrict {
        name    = "dotfiles-nickel";
        system  = host.system;
        builder = "/bin/sh";
        args    = [ "-c" ''
          ${unstable.legacyPackages.${host.system}.nickel}/bin/nickel \
            export "${nickel-source}/output.ncl" \
            --format "raw" \
          >$out
        ''];
      };
      filegen = derivationStrict {
        name    = "dotfiles-nickel";
        system  = host.system;
        builder = "/bin/sh";
        args    = [ "-c" ''
          ${unstable.legacyPackages.${host.system}.nickel}/bin/nickel \
            export "${nickel-source}/gen_filegen.ncl" \
          >$out
        ''];
      };
    in {
      default = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [ home-manager-nix.out ];

        # These are passed as extra arguments to the modules (functions)
        # I am avoiding `inherit` because it is confusing
        extraSpecialArgs = {
          system        = host.system;
          username      = host.username;
          dotfiles_dir  = dotfiles_dir;
          filegen       = builtins.fromJSON (builtins.readFile filegen.out);
          unstable      = import unstable {
            system = host.system;
            config.allowUnfree = true;
          };
        };
      };
    };
  };
}
