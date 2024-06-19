user="user"
podman run -it --rm \
  -v "..:/home/${user}/tocopy:ro" \
  dotfiles \
# end
