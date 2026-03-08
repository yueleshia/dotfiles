#run: nix eval --impure --expr 'import % rec { pkgs = import <nixpkgs> {}; unstable = pkgs; testpkgs = pkgs; }'

{ pkgs, unstable, testpkgs, ... }:
{
  home.packages = [
    unstable.nickel

    pkgs.gitui # rust
    pkgs.aerc
    pkgs.xan
    pkgs.neovim   pkgs.tree-sitter
    unstable.croc
    pkgs.reader
    #pkgs.jocalsend
    pkgs.remind
    #pkgs.remint
    pkgs.ffmpeg

    pkgs.dejsonlz4
    pkgs.podman

    pkgs.wayprompt # @TODO: For some, the tty version of pinentry-wayprompt does not work
    #pkgs.pinentry-curses
    #pkgs.pinentry-qt # @TODO: This breaks dinit for some reason...
    pkgs.mako pkgs.libnotify

    pkgs.tor-browser
    pkgs.stc-cli
    pkgs.transmission_4
    pkgs.clang-tools
    unstable.go
    unstable.rustup
    #unstable.zig
    pkgs.deno
    #unstable.bun # https://github.com/NixOS/nixpkgs/pull/313760

    pkgs.asciidoctor pkgs.rubyPackages.rouge
    pkgs.typst
    pkgs.qrcode
    pkgs.chafa
    pkgs.streamlink pkgs.yt-dlp-light
    #pkgs.mpv # I get `vo_x11_init: Assertion `!vo->x11' failed`
    pkgs.zathura pkgs.zathuraPkgs.zathura_pdf_mupdf
    pkgs.zathuraPkgs.zathura_cb pkgs.zathuraPkgs.zathura_ps
    #pkgs.opentofu
    #pkgs.ttdl
    #pkgs.todopy
    #pkgs.tuido
  ];

  i18n.inputMethod = {
    enable = true;
    type   = "fcitx5";

    fcitx5.waylandFrontend = true;
    fcitx5.addons = [
      #pkgs.fcitx5-qt
      pkgs.fcitx5-gtk
      pkgs.fcitx5-mozc
      pkgs.fcitx5-pinyin-zhwiki
      pkgs.qt6Packages.fcitx5-chinese-addons
      #pkgs.fcitx5-rime
      pkgs.fcitx5-hangul
      #pkgs.fcitx5-table-other
      pkgs.qt6Packages.fcitx5-configtool
    ];
  };

  # See: https://privacytests.org
  # I would prefer mullvad browser, but home-manager does not have it
  programs.librewolf = {
    enable = true;
    nativeMessagingHosts = [ pkgs.passff-host ];

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
}
