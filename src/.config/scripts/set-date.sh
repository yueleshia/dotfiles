#!/bin/sh

url="gnu.org"
printf %s\\n "=== Curling for ${url} time ===" >&2
datetime="$( curl -i "${url}" | sed -n '2s/^Date: //p' )"
date -d "${datetime}" || exit
sudo date -s "${datetime}"

