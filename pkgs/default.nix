#run: nix-build

{ pkgs ? import <nixpkgs> {} }:
pkgs.buildGoModule rec {
  pname   = "reader";
  version = "0.4.4";

  src = pkgs.fetchFromGitHub {
    owner = "mrusme";
    repo  = "reader";
    rev   = "v${version}";
    hash  = "sha256-wh0VtJuFY0A2lt87Fv3yQGDJhSpvWmlKqgQ4fSi6NQA=";
  };
  vendorHash = "sha256-0000000000000000000000000000000000000000000=";
  #vendorHash = "sha256-3W0cdwhzaaXaZnVjLzU2NtvCMJZ4kf0HdtIoJE7qksI=";

  #meta = {
  #  description = "";
  #  homepage = "https://github.com/mrusme/reader";
  #  license = lib.licenses.gpl3;
  #  #maintainers = with lib.maintainers; [ kalbasit ];
  #};
}

#{
#  description = "reader is for your command line what the “readability” view is for modern browsers: A lightweight tool offering better readability of web pages on the CLI.";
#  inputs = {
#    nixpkgs.url = "nixpkgs";
#  };
#  outputs = { self, nixpkgs }:
#    let
#    build = system: pkgs: ;
#    in
#
#  ;
#}
