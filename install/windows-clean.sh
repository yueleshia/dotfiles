list="$( winget.exe list )"
remove() {
  # Winget progress bar is sent to STDOUT
  count="$( printf %s\\n "${list}" | sed -n '1s/^.*Name/Name/p' | sed -n 's/Id.*//p' )"
  # In `|Name      |Id` count between the pipes
  count="${#count}"

  opt="$( printf %s\\n "${list}" | grep -m 1 "${1}" )" \
    || { printf %s\\n "$1 is already removed" >&2; return; }
  opt="$( printf %s\\n "${opt}" \
    | awk '{ print substr($0, '"${count}"' + 1); }' \
    | awk '{ print $1; }'
  )"
  printf %s\\n "Removing $1 '${opt}'" >&2
  winget.exe uninstall "${opt}"
}

winget.exe uninstall "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe"
winget.exe uninstall "Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe"
winget.exe uninstall "Microsoft.Services.Store.Engagement_8wekyb3d8bbwe"
remove "Cortana"
remove "MSN Weather"
remove "Power Automate"
remove "Microsoft Camera"
remove "Microsoft Sticky Notes"
remove "Microsoft Maps"
remove "Microsoft People"
remove "Microsoft Tips"
remove "Microsoft To Do"
remove "Xbox"
remove "Xbos Game Bar Plugin"
remove "Xbos Identity Provider"
