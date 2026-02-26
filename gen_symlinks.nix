#run: nix-instantiate --eval --strict --raw % | tee src/gen_symlinks.ncl

# We generate these as individual links so that home-manager does not add ./src
# to the store. We want it to add the invdividual files

let
  file_nodes = import ./pkgs/walkdir.nix { target = toString ./src; };

  start_with = prefix: s: prefix == (builtins.substring 0 (builtins.stringLength prefix) s);
  close_with = suffix: s:
    let
      suffix_len = builtins.stringLength suffix;
      total_len  = builtins.stringLength s;
    in
    suffix == (builtins.substring (total_len - suffix_len) total_len s)
  ;
  strip_mk_ncl = x: (if x.dir == "" then "" else x.dir + "/") + (builtins.substring 4 ((builtins.stringLength x.name) - 8) x.name);
  strip_mk     = x: (if x.dir == "" then "" else x.dir + "/") + (builtins.substring 4 (builtins.stringLength x.name) x.name);

  gen_files = builtins.filter (x: start_with "_mk_" x.name) file_nodes;
  as_path   = acc: x: "${acc}\n    ${builtins.toJSON (strip_mk     x)} = ${builtins.toJSON x.src},";
  as_import = acc: x: "${acc}\n    ${builtins.toJSON (strip_mk_ncl x)} = import ${builtins.toJSON x.src},";
  a = "";
  b = "";
in
''
{
  direct = {${builtins.foldl' as_path "" (builtins.filter (x: !close_with ".ncl" x.name) gen_files)}
  },
  to_import = {${builtins.foldl' as_import "" (builtins.filter (x: close_with ".ncl" x.name) gen_files)}
  },
}
''
