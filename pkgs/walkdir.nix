# This is used for generating a gen_filegen.ncl at preprocessor time

#run: nix-instantiate --eval --strict --argstr target "${PWD}/../src" --json %

{target}: let

read_dir = dir: builtins.attrValues(
  builtins.mapAttrs
  (name: type: { name = name; dir = dir; type = type; })
  (builtins.readDir dir)
);
strip_basedir = dir:
  builtins.substring
  ((builtins.stringLength target) + 1) # strip parent_dir and "/"
  (builtins.stringLength  dir)         # strip ".ncl"
  dir
;

walkdir_for_mk = src__out: todo_dir_list:
  let
  inodes      = builtins.concatLists(map read_dir todo_dir_list);
  dir__nodes  = builtins.filter (x: x.type == "directory") inodes;
  file_nodes  = builtins.filter (x: x.type == "symlink" || x.type == "regular" || x.type == "directory") inodes;

  paths_dir = map (x: "${x.dir}/${x.name}") dir__nodes;
  paths_ncl = map
    (x: {
      src  = strip_basedir "${x.dir}/${x.name}";
      dir  = strip_basedir x.dir;
      name = x.name;
    })
    file_nodes
  ;
  in

  if (builtins.length paths_dir) > 0
  then walkdir_for_mk (src__out ++ paths_ncl) paths_dir
  else src__out ++ paths_ncl
;

in
walkdir_for_mk [] [target]
