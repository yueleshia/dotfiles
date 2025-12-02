dir="./passbackup"
for relpath in $( find "${dir}"/* -type f ); do
  printf %s\\n "${relpath}"
  <"${relpath}" clipboard.sh -w
  x="${relpath#"${dir}/"}"
  x="${x%.gpg}"
  pass edit "${x}"
done
