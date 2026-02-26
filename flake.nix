#run: home-manager switch --flake .#port

{
  description = "Multi-Host Home Manager configuration";

  # To debug in `nix repl`, use load-flake `:lf .` which gives you access to `inputs`
  inputs = {
    nixpkgs.url  = "github:NixOS/nixpkgs/1267bb4920d0fc06ea916734c11b0bf004bbe17e"; # nixos-25.15   #nixpkgs.url  = "nixpkgs";
    unstable.url = "github:NixOS/nixpkgs/cf59864ef8aa2e178cccedbe2c178185b0365705"; #unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    testpkgs.url = "github:NixOS/nixpkgs/cf59864ef8aa2e178cccedbe2c178185b0365705"; # For incremental upgrades

    home-manager = { url = github:nix-community/home-manager/release-25.11; inputs.packages.follows = "nixpkgs"; };

    #mktoc        = { url = path:./pkgs/mktoc;  inputs.packages.follows = "nixpkgs"; };
    #reader       = { url = path:./pkgs/reader; inputs.packages.follows = "nixpkgs"; };
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
    environment   = builtins.fromJSON (builtins.readFile "${nickel-source}/gen_environment.json");

    output_nix = derivationStrict {
      name    = "dotfiles-nickel";
      system  = environment.system;
      builder = "/bin/sh";
      args    = [ "-c" ''${unstable.legacyPackages.${environment.system}.nickel}/bin/nickel \
        export "${nickel-source}/output.ncl" --format "raw" \
      >$out''];
    };
    filegen = derivationStrict {
      name    = "dotfiles-nickel";
      system  = environment.system;
      builder = "/bin/sh";
      args    = [ "-c" ''${unstable.legacyPackages.${environment.system}.nickel}/bin/nickel \
        export "${nickel-source}/gen_symlinks.ncl" \
      >$out''];
    };
    #output = import output_nix.out { };


    #pkgs = nixpkgs.legacyPackages.${environment.system};
    #lib  = nixpkgs.lib;
    #asdf = pkgs.runCommandLocal "a.pdf" {} ''
    #  mkdir -p $out/bin
    #  ln -s /home/rai/dotfiles/a $out/bin/hello
    #'';
  in {
    ## zaynetro.com/post/2024-you-dont-need-home-manager-nix
    #packages.${environment.system}.default = pkgs.symlinkJoin {
    #  name  = "my-packages";
    #  paths = [
    #    #pkgs.cowsay
    #    asdf
    #  ];
    #};

    homeConfigurations = {
      # Nix modules are the equivalent of `import home-manager-nix.out inputs`
      default = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = environment.system; };
        modules = [
          (import output_nix.out)
          ({ pkgs, ... }: {
            home.username      = environment.username;

            # Do not change this even if upgrading HM. Read release notes before changing.
            home.stateVersion = "25.11";

            # On first run will have to -- enable nix-command and flakes
            nix = {
              package                        = pkgs.nix;
              registry.nixpkgs.flake         = nixpkgs;  # Force flake install to follow nixpkgs?
              settings.experimental-features = ["nix-command" "flakes"];
            };

            # Packages to be in my path
            home.packages = [
            ];

            # @TODO: assert that there are no overlaps, probably on the nickel side?
            home.file =
              (builtins.fromJSON (builtins.readFile filegen.out)).to_import
              // {
                #".screenrc".source = dotfiles/screenrc;
                #".gradle/gradle.properties".text = ''
                #  org.gradle.daemon.idletimeout=3600000
                #'';
              }
            ;

            # If you don't want to manage your shell through HM, then source
            #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
            home.sessionVariables = { };

            # Let Home Manager install and manage itself.
            programs.home-manager.enable = true;
          })
        ];

        # These are passed as extra arguments to the modules (functions)
        # I am avoiding `inherit` because i#t is confusing
        extraSpecialArgs = {
          unstable      = import unstable { system = environment.system; config.allowUnfree = true; };
          testpkgs      = import testpkgs { system = environment.system; config.allowUnfree = true; };
          flakes        = builtins.mapAttrs
            (field: value: value.packages."${environment.system}".default)
            (builtins.removeAttrs inputs [ "nixpkgs" "unstable" "home-manager" ])
          ;
        };
      };
    };
  };
}
