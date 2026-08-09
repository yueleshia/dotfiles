#let contracts = import "meta/contracts.ncl" in

## Channels
#home-manager https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz
#nixpkgs https://nixos.org/channels/nixos-24.05
#unstable https://nixos.org/channels/nixpkgs-unstable


# https://blog.patapon.info/nixos-systemd-sway/

# For dependency injection
let env    = import "gen_environment.json" in
let inputs = (import "inputs.ncl").args in

let AbsPath = std.contract.from_predicate (fun value =>
  'String == (std.typeof value) && 0 != (std.string.length value) && "/" == (std.string.substring 0 1 value)
) in

let shared = [
  #"%{inputs.pkgs}.git",         # Will need installed to even check out our repo

  #"%{inputs.testpkgs}.nickel",
  "%{inputs.pkgs}.eza", "%{inputs.pkgs}.ripgrep", "%{inputs.pkgs}.fd", "%{inputs.pkgs}.tree",
  "%{inputs.unstable}.helix",
  "%{inputs.pkgs}.tmux",
  "%{inputs.pkgs}.htop",
  "%{inputs.pkgs}.nmap", "%{inputs.pkgs}.unixtools.nettools", "%{inputs.pkgs}.dig",


  "%{inputs.pkgs}.lf",   "%{inputs.pkgs}.skim", "%{inputs.pkgs}.fzf" ,  "%{inputs.pkgs}.atool",
  "%{inputs.pkgs}.entr",
  "%{inputs.pkgs}.pass", "%{inputs.pkgs}.gnupg", "%{inputs.pkgs}.pinentry-curses",
  "%{inputs.pkgs}.parallel", # perl

  "%{inputs.pkgs}.jq",   "%{inputs.pkgs}.fx",
  "%{inputs.unstable}.lychee",
] in
let colour = "" in

let home = "/home/%{env.username}" in
{
  current_profile = profiles."%{env.profile}",
  profiles  = {
    personal = {
      packages = shared @ [
        "%{inputs.unstable}.nickel",

        "%{inputs.pkgs}.aerc",
        "%{inputs.pkgs}.xan",
        "%{inputs.pkgs}.neovim",   "%{inputs.pkgs}.tree-sitter",
        "%{inputs.unstable}.croc",
        "%{inputs.pkgs}.reader",

        "%{inputs.pkgs}.podman",


        "%{inputs.pkgs}.stc-cli",
        "%{inputs.pkgs}.transmission",
        "%{inputs.pkgs}.clang-tools",
        "%{inputs.unstable}.go",
        #"%{inputs.unstable}.zig",
        "%{inputs.pkgs}.deno",
        #"%{inputs.unstable}.bun", # https://github.com/NixOS/nixpkgs/pull/313760

        "%{inputs.pkgs}.asciidoctor", "%{inputs.pkgs}.rubyPackages.rouge",
        "%{inputs.pkgs}.typst",
        "%{inputs.pkgs}.qrcode",
        "%{inputs.pkgs}.streamlink",
        #"%{inputs.pkgs}.opentofu",
        #"%{inputs.pkgs}.mpv",
        #"%{inputs.pkgs}.ttdl",
        #"%{inputs.pkgs}.todopy",
        #"%{inputs.pkgs}.tuido",
      ],

      base = {
        d  = "%{home}/dotfiles",
        dl = "%{home}/Downloads",
        e  = "%{home}/.environment",
        f  = "%{home}/Documents",
        m  = "%{home}/Music",
        p  = "%{home}/Pictures",
        t  = "/tmp",
        x  = "/mnt/a",
      },
      extra = m%"
        #wayland.windowManager.sway = {
        #  enable = true;
        #  config = rec {
        #    modifier = "Mod4";
        #    terminal = "kitty";
        #    startup  = [];
        #  };
        #};
      "%,
    },
    scratch = {
      packages = shared @ [
        "%{inputs.unstable}.croc",
      ],
      base = personal.base,
      extra = m%"
      "%,

    },
    devops = {
      packages = shared @ [
        "%{inputs.pkgs}.p7zip",
        "%{inputs.pkgs}.stc-cli",
        "%{inputs.pkgs}.gitui",    # rust
        "%{inputs.pkgs}.delta",    # rust
        "%{inputs.pkgs}.yq-go",    # go
        "%{inputs.pkgs}.xlsx2csv", # python
        "%{inputs.pkgs}.xan",      # rust
        #"%{inputs.flakes}.mktoc",  # rust
        "%{inputs.pkgs}.github-markdown-toc-go", # go
        "%{inputs.pkgs}.reader",   # go
        "%{inputs.unstable}.croc", # go

        "%{inputs.pkgs}.sxiv",
        "%{inputs.pkgs}.zathura",

        "%{inputs.pkgs}.oauth2c",
        "%{inputs.pkgs}.gh",
        #"%{inputs.pkgs}.git-filter-repo",
        "%{inputs.pkgs}.podman",
        "%{inputs.pkgs}.buildah",

        "%{inputs.pkgs}.azure-cli",   "%{inputs.pkgs}.azure-cli-extensions.azure-devops",
        "%{inputs.unstable}.awscli2", "%{inputs.pkgs}.ssm-session-manager-plugin",
        "%{inputs.pkgs}.mariadb",     "%{inputs.unstable}.rainfrog",
        #"%{inputs.pkgs}.sqlcmd",
        "%{inputs.pkgs}.sqlint",      "%{inputs.pkgs}.sqlcheck",
        "%{inputs.pkgs}.mongosh",     "%{inputs.pkgs}.mongodb-tools",

        "%{inputs.pkgs}.podman",
        "%{inputs.pkgs}.powershell",
        #"%{inputs.pkgs}.opentofu",
        "%{inputs.pkgs}.terragrunt", "%{inputs.pkgs}.terraform-ls",
        #"%{inputs.pkgs}.ansible",
        "%{inputs.pkgs}.deno",
        "%{inputs.pkgs}.go", "%{inputs.pkgs}.gopls",
        "%{inputs.pkgs}.python3",
        "%{inputs.pkgs}.graphviz", "%{inputs.pkgs}.d2",
        "%{inputs.pkgs}.nls",

        #"%{inputs.pkgs}.jsonnet-language-server",
        #"%{inputs.pkgs}.zbar-tools"
      ],
      base = {
        d  = "%{home}/dotfiles",
        dl = "%{env.external}/Downloads",
        e  = "%{home}/.environment",
        f  = "%{env.external}/Documents",
        m  = "%{env.external}/Music",
        p  = "%{env.external}/Pictures",
        t  = "/tmp",
        x  = env.external,
      },
      extra = m%"
      "%,
    },
  } |> std.record.map_values (fun profile =>
    let base | {
      d  | String, # dotfiles
      dl | String, # Downloads
      e  | String, # .env: local only files, not for git
      f  | String, # Documents (files)
      m  | String, # Music
      p  | String, # Pictures
      t  | String, # temp dir
      x  | String, # External, e.g. Windows home user, android Storage
    } = profile.base in
    let derived = base & {
      a  = dc        ++ "/vim/after",
      c  = h         ++ "/.config",
      cl = h         ++ "/.local",
      cr = c         ++ "/remind",
      d  = base.d,
      dc = base.d    ++ "/src/.config",
      dl = base.dl,
      do = base.d    ++ "/oci", # 'Open Container Intiative
      ds = base.d    ++ "/src",
      ec = base.e    ++ "/.config",
      f  = base.f,
      h  = home,
      i  = h         ++ "/interim",
      l  = base.e    ++ "/Library",
      m  = base.m,
      me = "/media",
      mn = "/mnt",
      n  = base.e    ++ "/notes",
      o  = base.d    ++ "/oci",
      p  = base.p,
      q  = base.dl   ++ "/queue",
      s  = dc        ++ "/scripts",
      t  = base.t,
      sn = dc        ++ "/snippets",
      ss = h         ++ "/.ssh",
      w  = h         ++ "/projects",
      x  = base.x,
      z  = base.e    ++ "/zettelkasten",
    } in

    {
      packages                            = profile.packages,
      named_directories | { _ | AbsPath } = derived,
      extra | String                      = profile.extra,
      direct_links      = {
        ".config/scripts"              = "%{derived.dc}/scripts",
        ".config/snippets"             = "%{derived.dc}/snippets",
        ".config/vim/after"            = "%{derived.dc}/vim/after",
        ".config/vim/init.vim"         = "%{derived.dc}/vim/init.vim",
        ".config/helix/config.toml"    = "%{derived.dc}/helix/config.toml",
        ".config/helix/languages.toml" = "%{derived.dc}/helix/languages.toml",
      },
      xdg_rel = {
        XDG_CACHE_HOME  = ".cache",       # analogous to /etc
        XDG_CONFIG_HOME = ".config",      # analogous to /var/cache
        XDG_DATA_HOME   = ".local/share", # analogous to /usr/share
        XDG_STATE_HOME  = ".local/state", # analogous to /var/lib
      },
      xdg     = xdg_rel |> std.record.map_values (fun relpath => "%{home}/%{relpath}"),
    }
  ),
}
