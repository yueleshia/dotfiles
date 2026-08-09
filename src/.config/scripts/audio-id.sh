#!/bin/sh

# https://github.com/SeaDve/Mousai
# https://github.com/itspoma/audio-fingerprint-identifying-python

die() { printf %s "${1}: " >&2; shift 1; printf %s\\n "$@" >&2; exit "${1}"; }

NL='
'
APIS="${NL}$( cat "${DOTENVIRONMENT}/tokens.csv" )" \
  || die FATAL 1 "Missing API token file"

read_csv() {
  line="${APIS#*"${NL}${1}",}"
  line="${line%%"${NL}"*}"
  printf %s "${line}"
}



[ $# = 1 ] || die FATAL 1 "Correct syntax is:" \
  "  $0 <file>" \
  "Identifies the song via audd.io"

curl https://api.audd.io/ \
  -F api_token="$( read_csv "audd.io")" \
  -F file=@"${1}" \
  -F return='apple_music,spotify' \
  | jq
