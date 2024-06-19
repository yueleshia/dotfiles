#run: nickel export % --field text --format raw

{ executable = true, text = m%"
#!/usr/bin/env sh
prompt() {
  if   [ -n "${DISPLAY}" ]; then         <&0 dmenu "$@"
  elif [ -n "${WAYLAND_DISPLAY}" ]; then <&0 dmenu-wl "$@"
  fi
}


while read -r path; do case "${1}" in
  d) [ "$( printf "No\\nYes" | prompt -i -p "Confirm delete?" )" = "Yes" ] \
    && rm "${path}" ;;
  p) notify-send -t 2000 "${path}" ;;
esac done

"% }
