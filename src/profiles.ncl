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
  "%{inputs.pkgs}.eza", "%{inputs.pkgs}.ripgrep", "%{inputs.pkgs}.fd",
  "%{inputs.pkgs}.tree", "%{inputs.pkgs}.which",
  "%{inputs.unstable}.helix",
  "%{inputs.pkgs}.tmux",
  "%{inputs.pkgs}.htop",
  "%{inputs.pkgs}.nmap", "%{inputs.pkgs}.net-tools", "%{inputs.pkgs}.dig",

  "%{inputs.pkgs}.lf", "%{inputs.pkgs}.chafa",
  "%{inputs.pkgs}.skim", "%{inputs.pkgs}.fzf",
  "%{inputs.pkgs}.entr",
  "%{inputs.pkgs}.pass", "%{inputs.pkgs}.gopass", "%{inputs.pkgs}.gnupg",
  #"%{inputs.pkgs}.pinentry-curses",
  #"%{inputs.pkgs}.pinentry-qt", # @TODO: This breaks dinit for some reason...
  "%{inputs.pkgs}.parallel", # perl
  "%{inputs.pkgs}.rsync",

  "%{inputs.pkgs}.atool",
  #"%{inputs.pkgs}.tar",
  #"%{inputs.pkgs}.xz",
  "%{inputs.pkgs}.zip", "%{inputs.pkgs}.unzip",

  "%{inputs.pkgs}.jq",   "%{inputs.pkgs}.fx",
  "%{inputs.unstable}.lychee",
] in

let home = "/home/%{env.username}" in
{
  current_profile = profiles."%{env.profile}",
  profiles  = {
    personal = {
      packages = shared @ [
        "%{inputs.unstable}.nickel",

        "%{inputs.pkgs}.gitui", # rust
        "%{inputs.pkgs}.aerc",
        "%{inputs.pkgs}.xan",
        "%{inputs.pkgs}.neovim",   "%{inputs.pkgs}.tree-sitter",
        "%{inputs.unstable}.croc",
        "%{inputs.pkgs}.reader",
        #"%{inputs.pkgs}.jocalsend",
        "%{inputs.pkgs}.remind",
        #"%{inputs.pkgs}.remntui",
        "%{inputs.pkgs}.ffmpeg",

        "%{inputs.pkgs}.dejsonlz4",
        "%{inputs.pkgs}.podman",

        #"%{inputs.pkgs}.wayprompt", # @TODO: For some, the tty version of pinentry-wayprompt does not work
        "%{inputs.pkgs}.mako", "%{inputs.pkgs}.libnotify",
        "%{inputs.pkgs}.swayimg",

        "%{inputs.pkgs}.tor-browser",
        "%{inputs.pkgs}.stc-cli",
        "%{inputs.pkgs}.transmission_4",
        "%{inputs.pkgs}.clang-tools",
        "%{inputs.unstable}.go",
        "%{inputs.unstable}.rustup",
        #"%{inputs.unstable}.zig",
        "%{inputs.pkgs}.deno",
        #"%{inputs.unstable}.bun", # https://github.com/NixOS/nixpkgs/pull/313760

        "%{inputs.pkgs}.asciidoctor", "%{inputs.pkgs}.rubyPackages.rouge",
        "%{inputs.pkgs}.typst",
        "%{inputs.pkgs}.qrcode",
        "%{inputs.pkgs}.streamlink", "%{inputs.pkgs}.yt-dlp-light",
        "%{inputs.pkgs}.mpv",
        "%{inputs.pkgs}.zathura", "%{inputs.pkgs}.zathuraPkgs.zathura_pdf_mupdf",
        "%{inputs.pkgs}.zathuraPkgs.zathura_cb", "%{inputs.pkgs}.zathuraPkgs.zathura_ps",
        #"%{inputs.pkgs}.opentofu",
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
        #home.activation = {
        #  post_bashrc = {
        #  };
        #};

        i18n.inputMethod = {
          enable = true;
          type   = "fcitx5";

          fcitx5.waylandFrontend = true;
          fcitx5.addons = [
            #%{inputs.pkgs}.fcitx5-qt
            %{inputs.pkgs}.fcitx5-gtk
            %{inputs.pkgs}.fcitx5-mozc
            %{inputs.pkgs}.fcitx5-pinyin-zhwiki
            %{inputs.pkgs}.qt6Packages.fcitx5-chinese-addons
            #%{inputs.pkgs}.fcitx5-rime
            %{inputs.pkgs}.fcitx5-hangul
            #%{inputs.pkgs}.fcitx5-table-other
            %{inputs.pkgs}.qt6Packages.fcitx5-configtool
          ];
        };

        # See: https://privacytests.org
        # I would prefer mullvad browser, but home-manager does not have it
        programs.librewolf = {
          enable = true;
          nativeMessagingHosts = [ %{inputs.pkgs}.passff-host ];

          # See: gist.github.com/heywoodlh/b6d0e7f01e4e8ce34e056f12935f8ea
          # firefox on MacOS seems to require workarounds
          #package = if pkgs.stdenv.isDarwin then pkgs.runCommand "firefox-0.0.0" {} "mkdir $out"

          # @TODO: I can install, but not download extensions in home-manager's
          #        LibreWolf. So nix installing extensions also does not work.
          # Use ../install/install-firefox-extensions.sh script to download
          # Check about:policies
          policies = {
            #DisableMasterPasswordCreation = true; # I use gopass

            #Extensions = {};
            ExtensionSettings = {
              "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}" = { private_browsing = false; }; # videospeed
              "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = { private_browsing = true; }; # localcdn
              "passff@invicem.pro"                     = { private_browsing = true; };
              "@testpilot-containers"                  = { private_browsing = true; };
              "uBlock0@raymondhill.net"                = { private_browsing = true; };
            };
          };

          profiles = {
            main = {
              id = 0;
              name = "main";
              isDefault = true;

              # Ideally, you want as close to defaults as possible to avoid fingerprinting
              settings = {
                "middlemouse.paste"           = false;
                "browser.gesture.swipe.left"  = "";
                "browser.gesture.swipe.right" = "";
              };

              #containers = {
              #  media  = { id = 0; name = ""; color = "green"; };
              #  retail = { id = 0; name = ""; color = "green"; };
              #  bank   = { id = 3; name = ""; color = "green"; };
              #};
              #search = {
              #  engines = {
              #    ""
              #  };
              #};
            };
          };
        };

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
