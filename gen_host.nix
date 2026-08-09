#run: nix-instantiate % --eval --strict --argstr username me --argstr external /tmp --argstr dotfiles /home/me/dotfiles/src --json -A test >src/gen_host.json

{ username, external } @ input:
let
  home  = "/home/${username}";
  # @TODO: assert all of base is contained in parse_dirs

  # do `d = base.d` instead of `base // rec {` so we can visually see all named_directories
  expand = base: rec {
    a  = dc        + "/vim/after";
    c  = home      + "/.config";
    cl = home      + "/.local";
    cr = c         + "/remind";
    d  = home      + "/dotfiles";
    dc = d         + "/src/.config";
    dl = base.dl;
    do = d         + "/oci"; # 'Open Container Intiative
    ds = d         + "/src";
    e  = home      + "/.environment";
    f  = base.f;
    h  = home;
    i  = home      + "/interim";
    l  = e         + "/Library";
    m  = base.m;
    mn = "/mnt";
    n  = e         + "/notes";
    o  = d         + "/oci";
    p  = base.p;
    q  = base.dl   + "/queue";
    s  = dc        + "/scripts";
    t  = base.t;
    sn = dc        + "/snippets";
    ss = home      + "/.ssh";
    w  = home      + "/projects";
    x  = external;
    z  = e         + "/zettelkasten";
  };

  std = tmp: expand {
    dl = "${home}/Downloads";
    f  = "${home}/Documents";
    m  = "${home}/Music";
    p  = "${home}/Pictures";
    t  = tmp;
  };
in
builtins.mapAttrs
(k: v: v // input // {
  XDG_CACHE_HOME  = "${home}/.cache";       # analogous to /etc
  XDG_CONFIG_HOME = "${home}/.config";      # analogous to /var/cache
  XDG_DATA_HOME   = "${home}/.local/share"; # analogous to /usr/share
  XDG_STATE_HOME  = "${home}/.local/state"; # analogous to /var/lib
})
{
  port   = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tmp"; dirs = std "/tmp"; };
  test   = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tm*"; dirs = std "/tmp"; };
  #termux = { system = "x86_64-linux"; profile = "personal"; external_glob = "/tm*"; dirs = std "/tmp"; };
  devops = { system = "x86_64-linux"; profile = "devops";   external_glob = "/mnt/c/Users/J[0-9]*"; dirs = expand {
    dl = "${external}/Downloads";
    f  = "${external}/Documents";
    m  = "${external}/Music";
    p  = "${external}/Pictures";
    t  = "/tmp";
  }; };
}
