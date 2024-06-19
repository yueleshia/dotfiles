#!/usr/bin/env sh

url="https://raw.githubusercontent.com/LukeSmithxyz/mutt-wizard/master/share/domains.csv"

require() {
  for dir in $( printf %s "${PATH}" | tr ':' '\n' ); do
    [ -f "${dir}/$1" ] && [ -x "${dir}/$1" ] && return 0
  done
  return 1
}

fetch() {
  require "$1" && { "$@"; exit 0; }
}

fetch curl -L "${url}" -o imap.csv  # -L follow redirects
fetch wget "${url}" -O imap.csv
fetch aria2c -c "${url}" -o imap.csv  # -c continue
