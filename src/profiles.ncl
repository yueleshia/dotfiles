#let contracts = import "meta/contracts.ncl" in

# For dependency injection
let env    = import "gen_environment.json" in
let inputs = (import "inputs.ncl").args in

let AbsPath = fun label value =>
  if 0 != (std.string.length value) && "/" == (std.string.substring 0 1 value)
  then value
  else label |> std.contract.blame_with_message "Not an absolute path: '%{value}'"
in

let shared = [
  "%{inputs.unstable}.nickel",
  "%{inputs.pkgs}.eza", "%{inputs.pkgs}.ripgrep", "%{inputs.pkgs}.fd", "%{inputs.pkgs}.tree",
  "%{inputs.pkgs}.helix",
  "%{inputs.pkgs}.tmux",
  "%{inputs.pkgs}.nmap", "%{inputs.pkgs}.unixtools.nettools", "%{inputs.pkgs}.dig",


  "%{inputs.pkgs}.lf",   "%{inputs.pkgs}.fzf" ,  "%{inputs.pkgs}.atool",
  "%{inputs.pkgs}.pass", "%{inputs.pkgs}.gnupg", #"%{inputs.pkgs}.pinentry",
  "%{inputs.pkgs}.pinentry-curses",

  "%{inputs.pkgs}.jq",
] in
let colour = "" in

let home = "/home/%{env.username}" in
let dirs_to_link = [
] in

{
  current_profile = profiles."%{env.profile}",
  profiles  = {
    personal = {
      packages = shared @ [
        "%{inputs.pkgs}.git",
        "%{inputs.pkgs}.aerc",
        "%{inputs.unstable}.go",
        "%{inputs.pkgs}.neovim",   "%{inputs.pkgs}.tree-sitter",
        "%{inputs.pkgs}.entr",
        "%{inputs.pkgs}.podman",

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
    },
    devops = {
      packages = shared @ [
        "%{inputs.pkgs}.parallel",
        "%{inputs.pkgs}.gitui",

        "%{inputs.pkgs}.sxiv",
        "%{inputs.pkgs}.zathura",

        "%{inputs.pkgs}.gh",
        #"%{inputs.pkgs}.git-filter-repo",
        "%{inputs.pkgs}.podman",
        "%{inputs.pkgs}.buildah",

        "%{inputs.pkgs}.azure-cli",
        #"%{inputs.unstable}.awscli2",
        "%{inputs.pkgs}.mysql",
        "%{inputs.pkgs}.sqlcmd",
        "%{inputs.pkgs}.sqlint", "%{inputs.pkgs}.sqlcheck",

        "%{inputs.pkgs}.powershell",
        "%{inputs.pkgs}.terraform", "%{inputs.pkgs}.terraform-ls",
        #"%{inputs.pkgs}.ansible",
        "%{inputs.pkgs}.deno",
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
      a  = dc      ++ "/vim/after",
      c  = h       ++ "/.config",
      cl = h       ++ "/.local",
      cr = c       ++ "/remind",
      dc = base.d  ++ "/src/.config",
      do = base.d  ++ "/oci", # 'Open Container Intiative
      ds = base.d  ++ "/src",
      ec = base.e  ++ "/.config",
      h  = home,
      i  = h       ++ "/interim",
      l  = base.e  ++ "/Library",
      me = "/media",
      mn = "/mnt",
      n  = base.e  ++ "/notes",
      o  = base.d  ++ "/oci",
      q  = base.dl ++ "/queue",
      s  = dc      ++ "/scripts",
      sn = dc      ++ "/snippets",
      ss = h       ++ "/.ssh",
      w  = h       ++ "/projects",
      z  = base.e  ++ "/zettelkasten",
    } in

    {
      packages          = profile.packages,
      named_directories | { _ | AbsPath } = derived,
      dir_links         = {
        ".config/scripts"   = "%{derived.dc}/scripts",
        ".config/snippets"  = "%{derived.dc}/snippets",
        ".config/vim/after" = "%{derived.dc}/vim/after",
      },
      xdg_rel           = {
        XDG_CACHE_HOME  = ".cache",       # analogous to /etc
        XDG_CONFIG_HOME = ".config",      # analogous to /var/cache
        XDG_DATA_HOME   = ".local/share", # analogous to /usr/share
        XDG_STATE_HOME  = ".local/state", # analogous to /var/lib
      },
      xdg               = xdg_rel |> std.record.map_values (fun relpath => "%{home}/%{relpath}"),
    }
  ),
}
