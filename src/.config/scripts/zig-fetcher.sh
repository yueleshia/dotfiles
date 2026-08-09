#!/bin/sh

printf %s\\n "=== Downloading the latest zig version ===" >&2
html="$( curl -L https://ziglang.org/download )" || exit "$?"

x="$( printf %s\\n "${html}" \
  | grep -o '"https://.*\.tar\.xz"' \
  | sort \
  | fzf --query "builds/x86_64-linux" \
)" || exit "$?"
url="$( printf %s\\n "${x}" | tr -d '"' )"
folder="${url##*/}"

version="$( zig version )" || version=""
if [ "${url#*-dev}" = "${version#*-dev}" ]; then
  printf %s\\n "You already have ${version} on your current computer" >&2
  exit 1
else
  printf %s\\n "Updating ${version#*-dev} -> ${url#*-dev}" >&2
fi
curl -L "${url}" -o "/tmp/zig.tar.xz"

printf %s\\n "=== Extracting ===" >&2
[ -d "/tmp/zig" ] && rm -r /tmp/zig
mkdir -p /tmp/zig
tar xvf /tmp/zig.tar.xz -C /tmp/zig || exit "$?"
d=~/.local/lib/zig; [ -d "${d}" ] && rm -r "${d}"
mv "/tmp/zig/${folder%.tar.xz}/lib" "${d}"
mv "/tmp/zig/${folder%.tar.xz}/zig" ~/.local/bin/zig
rm -r /tmp/zig || exit "$?"

zig version
