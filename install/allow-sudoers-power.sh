#!/bin/sh

halt="$( which halt )" || exit "$?"
reboot="$( which reboot )" || exit "$?"
poweroff="$( which poweroff )" || exit "$?"

NL='
'
allow="%wheel ALL=(ALL:ALL) NOPASSWD: ${halt}, ${reboot}, ${poweroff}"
printf %s\\n "Adding:" "  ${allow}" >&2

if sudo grep -v '^#' /etc/sudoers | grep -F "${allow}" >/dev/null; then
  printf %s\\n "Already present" >&2
  exit 0
else
  printf %s "Is this fine? (y/N)" >&2; IFS= read -r yn
  if [ "${yn}" != "y" ] && [ "${yn}" != "Y" ]; then
    exit 1
  fi
  sudo sh -c "printf %s '${NL}${allow}${NL}' >>/etc/sudoers"
fi
