#run: home-manager switch --flake .#port

{
  description = "Multi-Host Home Manager configuration";

  inputs = {
    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-24.05"; #nixpkgs.url  = "nixpkgs";
    unstable.url = "github:NixOS/nixpkgs/bc0b105ed11afa4d073e2b60ce6b94c1a72253bc"; #unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    testpkgs.url = "github:NixOS/nixpkgs/bc0b105ed11afa4d073e2b60ce6b94c1a72253bc"; # For incremental upgrades
    home-manager = { url = github:nix-community/home-manager/release-24.05; inputs.packages.follows = "nixpkgs"; };

    mktoc        = { url = path:./pkgs/mktoc;  inputs.packages.follows = "nixpkgs"; };
    reader       = { url = path:./pkgs/reader; inputs.packages.follows = "nixpkgs"; };
  };

  outputs = { nixpkgs, unstable, testpkgs, home-manager, ... }@inputs: let
    # Define one host per key in ${hosts}
    # We are off-loading most of the configuration to nickel
    #
    # Host     is a physical computer
    # Profile  is a software setup
    # External is the extra 'home' directory that exists on Android/Windows
    nickel-source = builtins.path { path = ./src; }; # Copy ./src into store on nix realisation
    # This is how we get around flakes being mostly pure
    host          = builtins.fromJSON (builtins.readFile "${nickel-source}/gen_environment.json");

    home-manager-nix = derivationStrict {
      name    = "dotfiles-nickel";
      system  = host.system;
      builder = "/bin/sh";
      args    = [ "-c" ''${unstable.legacyPackages.${host.system}.nickel}/bin/nickel \
        export "${nickel-source}/output.ncl" --format "raw" \
      >$out''];
    };
    filegen = derivationStrict {
      name    = "dotfiles-nickel";
      system  = host.system;
      builder = "/bin/sh";
      args    = [ "-c" ''${unstable.legacyPackages.${host.system}.nickel}/bin/nickel \
        export "${nickel-source}/gen_filegen.ncl" \
      >$out''];
    };
  in {
    homeConfigurations = {
      # Nix modules are the equivalent of `import home-manager-nix.out inputs`
      default = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = host.system; };
        modules = [ home-manager-nix.out ];

        # These are passed as extra arguments to the modules (functions)
        # I am avoiding `inherit` because it is confusing
        extraSpecialArgs = {
          system        = host.system;
          filegen       = builtins.fromJSON (builtins.readFile filegen.out);
          unstable      = import unstable { system = host.system; config.allowUnfree = true; };
          testpkgs      = import testpkgs { system = host.system; config.allowUnfree = true; };
          root_inputs   = inputs;
          flakes        = builtins.mapAttrs
            (field: value: value.packages."${host.system}".default)
            (builtins.removeAttrs inputs [ "nixpkgs" "unstable" "home-manager" ])
          ;
        };
      };
    };
  };
}
