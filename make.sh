#!/bin/sh

# This script relies only on POSIX-shellscript syntax and nix builtins.
# Because we are installing our environment, we do not have any dependencies.

if [ "${0}" != "${0%%/*}" ]; then wd="${0%%/*}"; else wd="/"; fi
cd "${wd}" || exit "$?"

#run: ./% test

main() {
  if ! command -v "nix" >/dev/null 2>/dev/null; then
    script="$( curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)" || exit "$?"
    sh "${script}" --no-daemon || exit "$?"
  fi
  if ! command -v "home-manager" >/dev/null 2>/dev/null; then
    url="$( nix-instantiate --eval --raw --expr '(import ./flake.nix).inputs.home-manager.url' )" || exit "$?"
    nix-channel --add "https://github.com/nix-community/home-manager/archive/${url##*/}.tar.gz" home-manager || exit "$?"
    nix-channel --update || exit "$?"
    nix-shell '<home-manager>' -A install || exit "$?"
    nix-channel --remove home-manager
  fi

  choice="${1}"
  if [ -z "${choice}" ]; then
    printf %s\\n "Expected 1 argument. Please give one of the following:" >&2
    hosts="$( nix-instantiate --eval --expr '
      builtins.trace (toString (builtins.attrNames (import ./hosts.nix))) 0
    ' 2>&1 >/dev/null )" || exit "$?"
    for valid_host in ${hosts#trace: }; do
      printf %s\\n "* ${valid_host}" >&2
    done
    exit 1
  fi

  write_environment_ncl "me" "/tmp"
  base="$( nix-instantiate --arg target "\"${PWD}/src\"" --eval "walkdir.nix" 2>&1 >/dev/null )" || {
    printf %s\\n "${base}" >&2
    exit 1
  }
  printf %s\\n "${base#trace: }" >"src/gen_filegen.ncl"
  glob="$( nix-instantiate --eval --expr '
    (import ./hosts.nix).'"${choice}"'.external_glob
  ' )" || exit "$?"
  glob=${glob#\"}
  glob=${glob%\"}
  deglob="$( printf %s\\n ${glob} )"
  write_environment_ncl "${USER}" "${deglob}"

  home-manager switch --extra-experimental-features "nix-command flakes" --flake ".#default" --show-trace

  # Do not disturb git history
  write_environment_ncl "me" "/tmp"
}

provision_nix() {
  curl -L https://nixos.org/nix/install | sh
  # @TODO figure out --daemon
  # defaults to --no-daemon
}

provision_home_manager() {
  nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
  nix-channel --update
  ~/.nix-profile/bin/nix-shell '<home-manager>' -A install
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

prompt() {
  printf %s "${2}" >&2; read -r value || return "$?"; printf %s\\n "" >&2
  while :; do
    for opt in ${1}; do [ "${opt}" = "${value}" ] && break 2; done # break while loop
    printf %s\\n%s "${3}" "${2}" >&2; read -r value || return "$?"; printf %s\\n "" >&2
  done
  printf %s "${value}"
}

<&0 main "$@"
