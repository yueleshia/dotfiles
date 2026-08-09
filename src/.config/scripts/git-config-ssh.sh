#!/bin/sh

host="$( <~/.ssh/config sed -n 's/^Host //p' | fzf --prompt '.ssh/config> ' )" || exit "$?"
x="git config --global \"url.git@${host}:${1}/.insteadOf\" \"https://github.com/${1}/\""
printf %s\\n "${x}" >&2
printf %s "Apply? (y/N) " >&2
IFS= read -r yn || exit "$?"
if [ y = "${yn}" ] || [ y = "${yn}" ]; then
  git config --global "url.git@${host}:${1}/.insteadOf" "https://github.com/${1}/"
fi
