#!/bin/sh

#run: % librewolf ~/.librewolf/main false

browser_exe="${1}"
profile_dir="${2}"
is_force="${3}"

extensions_json="${profile_dir}/extensions.json"
[ -r "${extensions_json}" ] || {
  printf %s\\n "The file '${extensions_json}' does not exist. Did you specify the second argument correctly?" >&2
  exit 1
}

printf %s\\n "" "I recommend opening ${browser_exe}"
printf %s "Enter to continue: " >&2; IFS= read -r 

if ! [ -d "${profile_dir}/extensions" ]; then
  printf %s\\n "Creating '${profile_dir}/extensions' because it does not exist" >&2
  mkdir "${profile_dir}/extensions" >&2
fi

for line in $(
  # Check {profile}/extensions.json for the id (not needed for first install)
  printf %s\\n "{b86e4813-687a-43e6-ab65-0bde4ab75758},https://addons.mozilla.org/firefox/downloads/file/4650561/localcdn_fork_of_decentraleyes-2.6.83.xpi"
  #printf %s\\n "uBlock0@raymondhill.net,https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
  printf %s\\n "uBlock0@raymondhill.net,https://addons.mozilla.org/firefox/downloads/file/4675310/ublock_origin-1.69.0.xpi"
  printf %s\\n "@testpilot-containers,https://addons.mozilla.org/firefox/downloads/file/4627302/multi_account_containers-8.3.6.xpi"
  printf %s\\n "passff@invicem.pro,https://addons.mozilla.org/firefox/downloads/file/4591422/passff-1.23.xpi"
  printf %s\\n "{7be2ba16-0f1e-4d93-9ebc-5164397477a9},https://addons.mozilla.org/firefox/downloads/file/3756025/videospeed-0.6.3.3.xpi"

  #printf %s\\n "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9},https://addons.mozilla.org/firefox/downloads/file/4630675/gopass_bridge-2.1.1.xpi"
  :
); do
  <<EOF IFS=, read -r id url
${line}
EOF
  printf %s\\n "=== ${url} ===" >&2
  entry="$( <"${extensions_json}" jq --arg id "${id}" '.addons[] | select(.id == $id)' )" || entry='null'
  if [ true = "${is_force}" ]; then
    :
  elif [ null = "${entry}" ]; then
    printf %s\\n "The extension ${url##*/} is not installed" >&2
  elif version="$( printf %s\\n "${entry}" | jq --raw-output '.version' )"; [ "${url}" = "${url%"-${version}.xpi"}" ]; then
    printf %s\\n "The extension ${url##*/} is not the version specified: ${url##*/} != ${version}" >&2
  else
    printf %s\\n "The extension ${url##*/} is already installed. Use the following to force installation" "  ${0##*/} ${browser_exe} ${profile_dir} true" >&2
    continue
  fi

  file="${profile_dir}/extensions/${id}.xpi"
  curl -L "${url}" -o "${file}" || exit 1
  "${browser_exe}" "${file}" &
  printf %s "Enter to continue: " >&2; IFS= read -r 
done

