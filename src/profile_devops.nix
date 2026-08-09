# https://blog.patapon.info/nixos-systemd-sway/

#run: nix eval --impure --expr 'import % rec { pkgs = import <nixpkgs> {}; unstable = pkgs; testpkgs = pkgs; }'

# WSL setup
{ pkgs, unstable, testpkgs, ... }:
{
  home.packages = [
    pkgs.pinentry-curses

    pkgs.p7zip
    pkgs.stc-cli
    pkgs.gitui    # rust
    pkgs.delta    # rust
    pkgs.yq-go    # go
    pkgs.xlsx2csv # python
    pkgs.xan      # rust
    #flakes.mktoc  # rust
    pkgs.github-markdown-toc-go # go
    pkgs.reader   # go
    unstable.croc # go

    pkgs.sxiv
    pkgs.zathura

    pkgs.oauth2c
    pkgs.gh
    #pkgs.git-filter-repo
    pkgs.podman
    pkgs.buildah

    pkgs.azure-cli   pkgs.azure-cli-extensions.azure-devops
    unstable.awscli2 pkgs.ssm-session-manager-plugin
    pkgs.mariadb     unstable.rainfrog
    #pkgs.sqlcmd
    pkgs.sqlint      pkgs.sqlcheck
    pkgs.mongosh     pkgs.mongodb-tools

    pkgs.podman
    pkgs.powershell
    #pkgs.opentofu
    pkgs.terragrunt pkgs.terraform-ls
    #pkgs.ansible
    pkgs.deno
    pkgs.go pkgs.gopls
    pkgs.python3
    pkgs.graphviz pkgs.d2
    #unstable.nls # This memory leaks with 100% CPU
  ];
}
