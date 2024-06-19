#!/bin/sh

require() {
  for dir in $( printf %s "${PATH}" | tr ':' '\n' ); do
    [ -f "${dir}/${1}" ] && [ -x "${dir}/${1}" ] && return 0
  done
  return 1
}

context="${1}"
image_name="${2}"

runtime="podman"
require podman || runtime="docker"
[ "$#" -lt 2 ]      && { printf %s\\n "USAGE: ${0##*/} <context-dir> <image-name>"; exit 1; }
[ -d "${context}" ] || { printf %s\\n "The context must be a directory: '${context}'"; exit 1; }

if podman inspect "${image_name}" >/dev/null; then
  if podman inspect "cache" >/dev/null; then
    podman rmi "cache"
  fi
  podman tag "${image_name}" "cache" || exit "$?"
  podman rmi "${image_name}"
fi
podman build "${context}" -f Dockerfile -t "${image_name}"
