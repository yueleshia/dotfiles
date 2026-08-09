#!/bin/sh
# Only have this script so that helix does not show an error on mode change
# when I do not have one of these installed
x="fcitx-remote";  command -v "${x}" 2>&1 >/dev/null && "${x}" "$@"
x="fcitx5-remote"; command -v "${x}" 2>&1 >/dev/null && "${x}" "$@"
