#run: ./make.sh port

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

  # Designed around copying ./src to the store only once
  #
  # LEGEND
  # Host     is a physical computer
  # Profile  is a software setup
  # External is the extra 'home' directory that exists on Android/Windows
  outputs = { nixpkgs, unstable, testpkgs, home-manager, ... }@inputs:
    let
      source_dir = builtins.path { path = ./src; }; # Copy ./src into store on nix realisation
      host       = builtins.fromJSON (builtins.readFile "${source_dir}/gen_host.json"); # Purity workaround
      pkgs       = nixpkgs.legacyPackages.${host.system};
    in

    {
      ## zaynetro.com/post/2024-you-dont-need-home-manager-nix
      #packages.${host.system}.default = pkgs.symlinkJoin {
      #  name  = "my-packages";
      #  paths = [
      #    pkgs.cowsay
      #  ];
      #};

      homeConfigurations = {
        # Nix modules are the equivalent of `import home-manager-nix.out inputs`
        default = home-manager.lib.homeManagerConfiguration {
          # home-manager calls modules with `{ config, pkgs, ... } // extraSpecialArgs`
          pkgs             = pkgs;
          extraSpecialArgs = {
            unstable      = import unstable { system = host.system; config.allowUnfree = true; };
            testpkgs      = import testpkgs { system = host.system; config.allowUnfree = true; };
            flakes        = builtins.mapAttrs
              (field: value: value.packages."${host.system}".default)
              (builtins.removeAttrs inputs [ "nixpkgs" "unstable" "home-manager" ])
            ;
          };

          modules = [
            (import "${source_dir}/profile.nix")
            (import "${source_dir}/profile_${host.profile}.nix")
            ({ config, pkgs, ... }: {
              home.homeDirectory = host.dirs.h;
              home.username = host.username;

              # Do not change this even if upgrading HM. Read release notes before changing.
              home.stateVersion = "25.11";

              # On first run will have to -- enable nix-command and flakes
              nix = {
                package                        = pkgs.nix;
                registry.nixpkgs.flake         = nixpkgs;  # Force flake install to follow nixpkgs?
                settings.experimental-features = ["nix-command" "flakes"];
              };

              home.packages = [
                #asdf = pkgs.runCommandLocal "a.pdf" {} ''
                #  mkdir -p $out/bin
                #  ln -s /home/rai/dotfiles/a $out/bin/hello
                #'';
              ];

              home.file =
                let
                  filegen_src = derivationStrict {
                    name    = "dotfiles-nickel";
                    system  = host.system;
                    builder = "/bin/sh";
                    args    = [ "-c" ''${unstable.legacyPackages.${host.system}.nickel}/bin/nickel \
                      export "${source_dir}/gen_symlinks.ncl" \
                    >$out''];
                  };
                  filegen = builtins.fromJSON (builtins.readFile filegen_src.out);
                  oos_symlink = config.lib.file.mkOutOfStoreSymlink;
                in

                (builtins.mapAttrs (field: value: { source = oos_symlink "${host.dirs.ds}/${value}"; }) filegen.direct)
                // filegen.to_import
                // (builtins.listToAttrs (builtins.attrValues (
                  builtins.mapAttrs
                  (k: v: { name = "${host.dirs.c}/named_directories/${k}"; value = { source = oos_symlink v; }; })
                  host.dirs)
                ))

                // {
                  ".config/scripts".source      = oos_symlink "${host.dirs.dc}/scripts";
                  ".config/snippets".source     = oos_symlink "${host.dirs.dc}/snippets";
                  ".config/vim/after".source    = oos_symlink "${host.dirs.dc}/vim/after";
                  ".config/vim/init.vim".source = oos_symlink "${host.dirs.dc}/vim/init.vim";
                }
                // {
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
        };
      };
    }
  ;
}
