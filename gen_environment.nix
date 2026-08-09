#run: nix-instantiate % --eval --strict --argstr username me --argstr external /tmp --argstr dotfiles /home/me/dotfiles/src --json -A port >src/gen_environment.json

{ username, external, dotfiles } @ input:

# these hosts can be called as: `home-manager switch --flake .#port`
builtins.mapAttrs (k: v: v // input) {
  docker  = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tmp"; };
  test    = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tm*"; };
  port    = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tmp"; };
  scratch = { system = "x86_64-linux"; profile = "scratch";  external_glob = "/tmp"; };
  work    = { system = "x86_64-linux"; profile = "devops";   external_glob = "/mnt/c/Users/J[0-9]*"; };
}
