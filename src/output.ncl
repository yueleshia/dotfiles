#run: nickel export % --format raw | tee /dev/stderr | nix-instantiate --eval -

# For dependency injection
let env     = import "gen_environment.json" in
let filegen = import "gen_symlinks.ncl" in
let inputs  = (import "inputs.ncl").args in
let profile = (import "profiles.ncl").current_profile in

m%"
{ %{inputs |> std.record.fields |> std.string.join ", "}, ... }:

# export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
{
  home.homeDirectory = "%{profile.named_directories.h}";

  # Packages to be in my path
  home.packages = [
    %{profile.packages |> std.string.join "\n"}

    #(builtins.getFlake (toString ./src/pkgs/mktoc)).packages."${system}".default
    #(import ./pkgs/mktoc {}).packages."${system}".default
    #(pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    #(pkgs.writeShellScriptBin "my-hello" ''
    #  echo "Hello, ${config.home.username}!"
    #'')
  ];

  # @TODO: assert that there are no overlaps, probably on the nickel side?
  home.file = let oos_symlink = %{inputs.config}.lib.file.mkOutOfStoreSymlink; in
    {
      %{
        profile.direct_links
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

      %{
        filegen.direct
        |> std.record.to_array
        |> std.array.map (fun x => "%{x.field |> std.serialize 'Json}.source = oos_symlink %{(env.dotfiles ++ "/" ++ x.value) |> std.serialize 'Json};")
        |> std.string.join "\n"
      }
    }
  ;

  %{profile.extra}
}
"%
