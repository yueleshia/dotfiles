#!/bin/sh

# This script relies only on POSIX-shellscript syntax and nix builtins.
# Because we are installing our environment, we do not have any dependencies.

#run: % port

cd "${0%/*}" || exit "$?"

main() {
  file=~/.nix-profile/etc/profile.d/nix.sh
  [ -x "${file}" ] && . "${file}" # if after first install and refreshed from .bashrc
  if ! command -v "nix" >/dev/null 2>/dev/null; then
    script="$( curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install )" || exit "$?"
    sh -c "${script}" --no-daemon || exit "$?"
    . "${file}" || exit "$?"
  fi
  if ! command -v "home-manager" >/dev/null 2>/dev/null; then
    url="$( nix-instantiate --eval --raw --expr '(import ./flake.nix).inputs.home-manager.url' )" || exit "$?"
    nix-channel --add "https://github.com/nix-community/home-manager/archive/${url##*/}.tar.gz" home-manager || exit "$?"
    nix-channel --update || exit "$?"
    nix-shell '<home-manager>' -A install || exit "$?"
    nix-channel --remove home-manager
  fi

  WD="$( nix-instantiate --eval --strict --raw --expr 'toString ./.' )" || exit "$?"
  choice="${1}"
  if [ -z "${choice}" ]; then
    printf %s\\n "Expected 1 argument. Please give one of the following:" >&2
    hosts="$( nix-instantiate --eval --strict --raw --expr '
      builtins.toString (builtins.attrNames (import ./gen_host.nix { username=""; external=""; }))
    ' )" || exit "$?"
    for valid_host in ${hosts#trace: }; do
      printf %s\\n "* ${valid_host}" >&2
    done
    exit 1
  fi

  # File generation 1
  nix-instantiate --eval --strict --raw "./gen_symlinks.nix" >"src/gen_symlinks.ncl" || exit "$?"

  # File generation 2
  glob="$( env "me" "/tmp" -A "${choice}.external_glob" --raw )" || exit "$?"
  deglob="$( printf %s\\n ${glob} )"
  env "${USER}" "${deglob}" -A "${choice}" --json >"src/gen_host.json"

  echo 'Make sure to create `mkdir ~/.config/dinit.d/boot.d`'
  home-manager switch --extra-experimental-features "nix-command flakes" --flake ".#default" --show-trace

  # Do not disturb git history
  env "me" "/tmp" -A "${choice}" --json >"src/gen_host.json"
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

env() {
  username="${1}"
  external="${2}"
  shift 2

  nix-instantiate --eval --strict \
    --argstr username "${username}" \
    --argstr external "${external}" \
    "$@" \
    "./gen_host.nix" \
  # end
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
