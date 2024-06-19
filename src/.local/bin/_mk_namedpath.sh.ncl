#run: sh -c "$( nickel export % --field text --format raw )" _ path a/hello
# run: nickel export % --field text --format raw

let dirs = (import "../../profiles.ncl").current_profile.named_directories in
let max_length = dirs
  |> std.record.fields
  |> std.array.fold_left (fun acc abv =>
    if (std.string.length abv) > acc
    then std.string.length abv
    else acc
  ) 0
in

let pad = fun target_len s =>
  std.array.generate (fun i =>
    if i < (std.string.length s)
    then std.string.substring i (i + 1) s
    else " "
  ) max_length
  |> std.string.join ""
in


{ executable = true, text = m%"
#!/bin/sh

help() {
<<EOF cat -
cat -
USAGE
  namedpath <subcommand> [<arg>]

SUBCOMMAND
  interactive [<query>]   Fuzzy find, starting with <query>, the named directory
  path        [path]      Evaluate a path with named_directories
EOF
}
main() {
  case "${1}"
  in '') help; exit 1
  ;; interactive)
    choice="$( menu "${2}"; printf a )" || exit "$?"
    path="/${choice##* /./}"
    path="${path%?a}"
    printf %s "${path}"
  ;; path)
    <<EOF IFS="/" read -r first rest
${2}
EOF
    if [ -z "${first}" ]; then
      printf %s "${2}"
    else
      path_rest="${shortcuts_trimmed#*//"${first}"/./}"
      if [ "${shortcuts_trimmed}" != "${path_rest}" ]; then
        printf %s "/${path_rest%%//*}"
        if [ -n "${rest}" ]; then
          printf %s "/${rest}"
        fi
      else
        printf %s "${2}"
      fi
    fi
  ;; *)
    printf %s\\n "Invalid subcommand: '${1}'"
    help
    exit 1
  esac
}

menu() {
  if   require "sk"; then
    shortcuts | sk  --no-sort --read0 --query "^${1}" --select-1 || exit "$?"
  elif require "fzf"; then
    shortcuts | fzf --no-sort --read0 --query "^${1}" --select-1 || exit "$?"
  else
    query="${1}"
    while [ -z "${query}" ] || ! value="$( shortcuts | grep -ze "^${query} */\\./" )"; do
      shortcuts >&2
      printf %s "> ^" >&2; read -r query
    done
    printf %s\\n "${value}"
  fi
}

shortcuts() {
  %{
    dirs
    |> std.record.map (fun abv path => "printf '%s\\n\\0' " ++ (std.serialize 'Json "%{pad max_length abv} /.%{path}"))
    |> std.record.values
    |> std.string.join "\n"
  }
}
shortcuts_trimmed=%{
  dirs
  |> std.record.map (fun abv path => "//%{abv}/.%{path}")
  |> std.record.values
  |> std.string.join ""
  |> std.serialize 'Json
}

require() { command -v "$1" >/dev/null 2>&1; }

<&0 main "$@"

"% }
