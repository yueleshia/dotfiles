backup="./passbackup"

# Because I all these passwords would be created by me, I do not need to cater for spaces or special characters
for x in $( find "${PASSWORD_STORE_DIR}"/* -type f ); do
  relpath="${x#*/.local/password-store/}"
  dir="$( dirname "${relpath}" )"
  mkdir -p "${backup}/${dir}"
  pass show "${relpath%.gpg}" >"${backup}/${relpath%.gpg}"
done

croc "${backup}"
