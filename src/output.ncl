#run: nickel export % --format raw | tee /dev/stderr | nix-instantiate --eval -

# For dependency injection
let inputs  = (import "inputs.ncl").args in
let profile = (import "profiles.ncl").current_profile in

let home_dir = "/home/%{inputs.username}" in

m%"
{ %{inputs |> std.record.fields |> std.string.join ", "}, ... }:

# export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
{
  home.username      = "%{inputs.username}";
  home.homeDirectory = "%{home_dir}";

  # On first run will have to -- enable nix-command and flakes
  nix = {
    package = %{inputs.pkgs}.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  # Do not change this even if upgrading HM. Read release notes before changing.
  home.stateVersion = "24.05";

  # Packages to be in my path
  home.packages = [
    %{profile.packages |> std.string.join "\n"}
  #  (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  #  (pkgs.writeShellScriptBin "my-hello" ''
  #    echo "Hello, ${config.home.username}!"
  #  '')
  ];

  # @TODO: assert that there are no overlaps, probably on the nickel side?
  home.file = let oos_symlink = %{inputs.config}.lib.file.mkOutOfStoreSymlink; in
    {
      %{
        profile.dir_links
        |> std.record.to_array
        |> std.array.map (fun x => "%{x.field |> std.serialize 'Json}.source = oos_symlink %{x.value |> std.serialize 'Json};")
        |> std.string.join "\n"
      }

      %{
        profile.named_directories
        |> std.record.fields
        |> std.array.map (fun nick =>
          let x = "%{profile.xdg_rel.XDG_CONFIG_HOME}/named_directories/%{nick}" |> std.serialize 'Json in
          "%{x}.source = oos_symlink %{profile.named_directories."%{nick}"|> std.serialize 'Json};"
        )
        |> std.string.join "\n"
      }
      #// configuration.files.make;
    }
    // (builtins.mapAttrs (src: text: { text = text; }) %{inputs.filegen})
  ;
  #{
  #  ".screenrc".source = dotfiles/screenrc;
  #  ".gradle/gradle.properties".text = ''
  #    org.gradle.daemon.idletimeout=3600000
  #  '';
  #};

  # If you don't want to manage your shell through HM, then source
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  home.sessionVariables = { };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
"%
