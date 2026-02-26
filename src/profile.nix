#run: nix eval --impure --expr 'import % rec { pkgs = import <nixpkgs> {}; unstable = pkgs; testpkgs = pkgs; }'

# shared packages
{pkgs, unstable, testpkgs, ...}: {
  home.packages = [
    #pkgs.git,         # Will need installed to even check out our repo

    #testpkgs.nickel,
    pkgs.eza pkgs.ripgrep pkgs.fd pkgs.tree
    unstable.helix
    pkgs.tmux
    pkgs.htop
    pkgs.nmap pkgs.net-tools pkgs.dig

    pkgs.lf   pkgs.skim pkgs.fzf
    pkgs.entr
    pkgs.pass pkgs.gopass pkgs.gnupg
    #pkgs.pinentry-curses
    #pkgs.pinentry-qt # @TODO: This breaks dinit for some reason...
    pkgs.parallel # perl
    pkgs.rsync

    pkgs.atool
    #pkgs.tar
    #pkgs.xz
    pkgs.zip pkgs.unzip

    pkgs.jq   pkgs.fx
    unstable.lychee
  ];
}
