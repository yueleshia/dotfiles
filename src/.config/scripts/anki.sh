#!/bin/sh

#run: % quiz 2 ~/.environment/notes/language/indo/vocab.tsv

action="${1}"
col="${2}"
tsv="${3}"

tab='	'

case "${action}"
in "")  printf %s\\n "Invalid action (1st argument)" >&2; exit 1
;; quiz)
  # Syntax check
  <"${tsv}" xsv count -d "${tab}" >/dev/null || exit "$?"

  [ -r "${tsv}" ] || { printf %s\\n "Cannot read: ${tsv}" >&2; exit "$?"; }

  # Take a sample so we don't get duplicates as often
  sample_size="15"
  sample=''

  while :; do
    # and skip first bool column
    [ -z "${sample}" ] && sample="$(
      <"${tsv}" grep "^1" \
      | cut -d "${tab}" -f "2-" \
      | shuf -n "${sample_size}" \
    )"

    line="$(   printf %s\\n "${sample}" | sed -n 1p )"
    sample="$( printf %s\\n "${sample}" | sed 1d )"

    printf %s "$( printf %s "${line}" | xsv select -d "${tab}" "${col}" )" >&2
    IFS= read -r input
    printf %s "${line}" | xsv select -d "${tab}" "!${col}" | xsv table -p 5  >&2
    printf \\n >&2

    case "${input}"
    in ?)
      key="$( printf %s\\n "${line}" | cut -d "${tab}" -f 1 )"
      handle.sh gui "https://en.wiktionary.org/wiki/${key}" 2>/dev/null
    esac
  done

  # end
;; *)  printf %s\\n "Invalid action (1st argument): '${action}'" >&2; exit 1
esac
