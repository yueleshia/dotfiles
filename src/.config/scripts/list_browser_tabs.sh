#!/bin/sh

#run: % ~/.librewolf/main 

profile_path="${1}"

x="$( dejsonlz4 "${profile_path}/sessionstore.jsonlz4" )" || exit "$?"
printf %s\\n "${x}" | jq '.
  | .windows
  | map(.tabs)
  | flatten
  | map(.entries)
  | flatten
  | map(.url)
  | map(select(startswith("about:") | not))
'
