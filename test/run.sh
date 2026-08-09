#!/bin/sh

#run: % true

is_build="${1}"
user="user"

if [ "${is_build}" = true ]; then
  PODMAN_IGNORE_CGROUPSV1_WARNING="" oci-build.sh . dotfiles || exit "$?"
  printf %s\\n "" "=== Done building ===" >&2
fi
podman run -it --rm \
  -v "..:/home/${user}/tocopy:ro" \
  -v "./inside-docker-make.sh:/home/${user}/make.sh:ro" \
  -u 1000:1000 \
  dotfiles \
# end
