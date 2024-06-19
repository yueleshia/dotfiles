{
  # these hosts can be called as: `home-manager switch --flake .#port`
  docker  = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tmp"; };
  test    = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tm*"; };
  port    = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tmp"; };
  scratch = { system = "x86_64-linux"; profile = "scratch";  external_glob = "/tmp"; };
  work    = { system = "x86_64-linux"; profile = "devops";   external_glob = "/mnt/c/Users/J[0-9]*"; };
}
