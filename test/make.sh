#!/bin/sh

image_name="dotfiles"

if podman inspect "${image_name}" >/dev/null; then
  if podman inspect "cache-${image_name}" >/dev/null; then
    podman rmi "cache-${image_name}"
  fi
  podman tag "${image_name}" "cache-${image_name}" || exit "$?"
  podman rmi "${image_name}"
fi
podman build .. -f Dockerfile -t "${image_name}"
