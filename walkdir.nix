# This is used for generating a gen_filegen.ncl at preprocessor time

{target}: let

read_dir = dir: builtins.attrValues(
  builtins.mapAttrs
  (name: type: { name = name; dir = dir; type = type; })
  (builtins.readDir dir)
);
ends_with     = suffix: s:
  let
  suffix_len = builtins.stringLength suffix;
  total_len  = builtins.stringLength s;
  in
  suffix == (builtins.substring (total_len - suffix_len) total_len s)
;
starts_with   = prefix: s: prefix == (builtins.substring 0 (builtins.stringLength prefix) s);
strip_basedir = dir:
  builtins.substring
  ((builtins.stringLength target) + 1) # strip parent_dir and "/"
  (builtins.stringLength  dir)         # strip ".ncl"
  dir
;
strip_mk_ncl  = name: builtins.substring 4 ((builtins.stringLength name) - 8) name;


walkdir_for_mk = src__out: todo_dir_list:
  let
  inodes      = builtins.concatLists(map read_dir todo_dir_list);
  dir__nodes  = builtins.filter (x: x.type == "directory")                      inodes;
  file_nodes  = builtins.filter (x: x.type == "symlink" || x.type == "regular") inodes;

  nickel_make = builtins.filter (x: starts_with "_mk_" x.name && ends_with ".ncl" x.name) file_nodes;

  paths_dir = map (x: "${x.dir}/${x.name}") dir__nodes;
  paths_ncl = map
    (x: {
      src = strip_basedir "${x.dir}/${x.name}";
      out = strip_basedir "${x.dir}/${strip_mk_ncl x.name}";
      dbg = "${x.dir}/${x.name}";
    })
    nickel_make
  ;
  in

  if (builtins.length paths_dir) > 0
  then walkdir_for_mk (src__out ++ paths_ncl) paths_dir
  else src__out ++ paths_ncl
;

joined_nickel_imports = builtins.foldl'
  (acc: x: "${acc}\n  ${builtins.toJSON x.out} = import ${builtins.toJSON x.src},")
  ""
  (walkdir_for_mk [] [target])
;
in

# Interpolate the '#' to dodge the comment integration in my workflow
builtins.trace ''
${"#"}run: echo '(import "%") |> std.record.map_values (fun x => x.executable)' | nickel export
{${joined_nickel_imports}
}'' ""

#run: nix-instantiate --eval --strict --arg target '"/home/rai/dotfiles/src"' %
