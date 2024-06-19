#!/bin/sh

# This script is built relying only on POSIX-shellscript syntax and nix builtins
# * 

if [ "${0}" != "${0%%/*}" ]; then wd="${0%%/*}"; else wd="/"; fi
cd "${wd}" || exit "$?"

#run: ./% test

main() {
  choice="${1}"
  [ -z "${choice}" ] && { printf %s\\n "No host provided as argument" >&2; exit 1; }

  write_environment_ncl "me" "/tmp"
  base="$( nix-instantiate --arg target "\"${PWD}/src\"" --eval "filegen.nix" 2>&1 >/dev/null )" || {
    printf %s\\n "${base}" >&2
    exit 1
  }
  printf %s\\n "${base#trace: }" >"src/gen_filegen.ncl"

  #hosts="$( nix-instantiate --log-format raw --eval --expr '
  #  toString (builtins.attrNames (import ./hosts.nix))
  #' )" || exit "$?"
  glob="$( nix-instantiate --eval --expr '
    (import ./hosts.nix).'"${choice}"'.external_glob
  ' )" || exit "$?"
  glob=${glob#\"}
  glob=${glob%\"}
  deglob="$( printf %s\\n ${glob} )"
  write_environment_ncl "${USER}" "${deglob}"

  home-manager switch --extra-experimental-features "nix-command flakes" --flake ".#default"

  # Do not disturb git history
  write_environment_ncl "me" "/tmp"
}

write_environment_ncl() {
  raw_json="$( nix-instantiate \
    --argstr username "${1}" \
    --argstr external "${2}" \
    --eval \
    --expr \
    '
      { username, external }: let
        base = (import ./hosts.nix).'"${choice}"' // {
          username = username;
          external = external;
        };
      in
      builtins.trace (builtins.toJSON base) ""
    ' \
  2>&1 >/dev/null )"
  printf %s\\n "${raw_json#trace: }" >"src/gen_environment.json"
}

<&0 main "$@"
