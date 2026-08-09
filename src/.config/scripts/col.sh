sep="${1}"
[ "!" = "${sep}" ] && { printf %s\\n "Cannot support '!' as a separator" >&2; exit 1; }

<&0 sed "s! *\${sep}!!g" | column --table --input-separator "${sep}" --output-separator "${sep}" --keep-empty-lines
