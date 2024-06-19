#run: nix build

{
  description = "Markdown Table of Content generator";
  inputs = {
    nixpkgs.url = "nixpkgs";
  };
  outputs = { self, nixpkgs }:
    let
    build = system: pkgs:
      pkgs.rustPlatform.buildRustPackage rec {
        pname   = "mktoc";
        version = "4.0.0";

        src = pkgs.fetchFromGitHub {
          owner = "KevinGimbel";
          repo  = pname;
          rev   = "v${version}";
          hash  = "sha256-Pq4o0t0cUrkXff+qSU5mlDo5A0nhFBuFk3Xz10AWDeo=";
        };

        cargoHash = "sha256-T7lGulBAcF9eFiDB38rBftu+47RnF74SV3j6qZhAfeE=";

        meta = {
          description = "Markdown Table of Content generator";
          homepage = "https://github.com/KevinGimbel/mktoc";
          license = pkgs.lib.licenses.mit;
          maintainers = [];
        };
      }
    ;
    in

    {
      packages.x86_64-linux.default = build "x86_64-linux" (import nixpkgs { system = "x86_64-linux"; });
    }
  ;
}
