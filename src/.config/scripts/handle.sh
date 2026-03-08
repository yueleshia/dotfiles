#!/usr/bin/env sh

NAME="$( basename "$0"; printf a )"; NAME="${NAME%?a}"

# Inspired from Ranger's 'scope.sh'
# Meanings of exit codes:
# code | meaning    | action of lf
# -----+------------+-------------------------------------------
# 0    | success    | Display stdout as preview
# 1    | no preview | Display no preview at all
# 2    | plain text | Display the plain content of the file

# Enums
ENUM_DEFAULT='0'

EXIT_PREVIEWSTDOUT='0'
EXIT_NOPREVIEW='1'  # Or error, or make ENUM_ERROR?
EXIT_PLAINTEXT='2'

PATH_TYPE="${ENUM_DEFAULT}"
ENUM_HYPERTEXT='1'
ENUM_FILE='2'

# No default
CMD_TERMINAL='2'
CMD_GUI='3'
CMD_PREVIEW='4'
CMD_EDIT='5'

main() {
  FLAG_DRYRUN=false
  cmd=''; file=''
  args=''; literal='false'; i=0
  for x in "$@"; do
    "${literal}" || case "${x}"
    in --)       literal='true'; continue
    ;; --dryrun) FLAG_DRYRUN=true; continue
    ;; -*)       printf %s\\n "Invalid flag '${x}'. Use '${0} -- ${x}' to ignore option parsing" >&2; exit 1
    esac

    i="$(( i + 1 ))"
    case "${i}"
    in 1) cmd="${x}"
    ;; 2) file="${x}"
    esac
  done

  [ -f "${file}" ] || { printf %s\\n "Invalid path '${file}'" >&2; exit 1; }

  case "${cmd}"
  in t|terminal)       COMMAND="${CMD_TERMINAL}"
  ;; g|gui)            COMMAND="${CMD_GUI}"
  ;; p|preview)        COMMAND="${CMD_PREVIEW}"
  ;; et|edit-terminal) COMMAND="${CMD_EDIT_TERM}"
  ;; eg|edit-gui)      COMMAND="${CMD_EDIT_GUI}"
  ;; *) printf %s\\n "invalid subcommand: \`$*\`" >&2; exit 1
  esac

  file_extension="$( printf %s\\n "${1##*.}" | tr '[:upper:]' '[:lower:]' )"
  HANDLE_TYPE='extension' handle_extension "${file}"

  mimetype="$( file --dereference --brief --mime-type -- "${file}" )" || exit 1
  HANDLE_TYPE='mime'      local_handle_mime "${file}"

  msg="Unknown extension '${file_extension}' and MIME type '${mimetype}'" >&2
  if [ -n "${TMUX}" ]; then
    tmux display-message -d 1000 "${msg}" &
  else
    printf %s\\n "${msg}" >&2
    exit 1
  fi

  exit "${EXIT_NOPREVIEW}"
}

#TODO think about to proceed with fallbacks or not (i.e. the early exit's)
handle_extension() {
  #echo local >&2
  case "${lowercase_extension}"
  in 7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
     rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
    p  "${EXIT_PREVIEWSTDOUT}" atool --list -- "${1}"

  ;; epub)
    g  "${EXIT_NOPREVIEW}" zathura -- "${1}"
    p  "${EXIT_PREVIEWSTDOUT}" exiftool "${1}"

  ;; pdf)
    # Preview as text conversion
    #eg "${EXIT_NOPREVIEW}" sigil
    t  "${EXIT_NOPREVIEW}" sh -c 'pdftotext -nopgbrk -q -- "${1}" - | "${EDITOR}"' _ "${1}"
    g  "${EXIT_NOPREVIEW}" zathura -- "${1}"

    # pdftotext is too slow for my tastes: -l lines, -q quiet
    #p  "${EXIT_PREVIEWSTDOUT}" pdftotext -l 2 -nopgbrk -q -- "${1}" -
    #p  "${EXIT_PREVIEWSTDOUT}" mutool draw -F txt -i -- "${1}" 1-10
    p  "${EXIT_PREVIEWSTDOUT}" exiftool "${1}"

  ## BitTorrent
  #;; torrent)
  #  transmission-show -- "${1}"
  #  exit "${EXIT_NOPREVIEW}"

  ## OpenDocument
  #;; odt|ods|odp|sxw)
  # p "${EXIT_PREVIEWSTDOUT}" odt2txt "${1}"
  #  exit "${EXIT_NOPREVIEW}"

  ;; doc|docx|xls|xlsx|ppt|pptx|ods)
    et "${EXIT_NOPREVIEW}"     "${EDITOR}""${1}"
    eg "${EXIT_NOPREVIEW}"     libreoffice "${1}"
    g  "${EXIT_NOPREVIEW}"     libreoffice "${1}"

  # HTML
  ;; htm|html|xhtml)
    et "${EXIT_NOPREVIEW}"     "${EDITOR}""${1}"
    t  "${EXIT_NOPREVIEW}"     browser.sh terminal link "${1}"
    g  "${EXIT_NOPREVIEW}"     browser.sh gui link "${1}"
    p  "${EXIT_PREVIEWSTDOUT}" w3m -dump "${1}"

  ;; 1)
    t  "${EXIT_PREVIEWSTDOUT}" man ./ "${1}" | col -b
  esac
}

# NOTE: Unquoted spaces in pattern match of case-structure are skipped
#       so `text/* | *xml)` is the same as `text/*|*xml)`
local_handle_mime() {
  case "${mimetype}"
  # Text
  in text/* | */xml)
    # Syntax highlight
    et "${EXIT_NOPREIVEW}"     "${EDITOR}" "${1}"
    t  "${EXIT_NOPREIVEW}"     "${EDITOR}" "${1}"
    g  "${EXIT_NOPREVIEW}"     "${EDITOR}" "${1}"
    p  "${EXIT_PREVIEWSTDOUT}" bat --color always --line-range '40:' --pager never -- "${1}"
    #exit_message 'mime' "${EXIT_PLAINTEXT}"  # Do not fallback

  # Image
  ;; image/*)
    eg "${EXIT_NOPREVIEW}" krita -- "${1}"
    t  "${EXIT_NOPREVIEW}" tmux new-window sh -c 'chafa -- "${1}"; read -n 1' _ "${1}"
    #g  "${EXIT_NOPREVIEW}" mpv --playlist-start="$( get_index_in_parent "${1}" )" "$( dirname "${1}" )"
    g  "${EXIT_NOPREVIEW}" mpv_image_viewer.pl "${1}"
    #p  "${EXIT_PREVIEWSTDOUT}" img2txt --gamma=0.6 -- "${1}"
    #p  "${EXIT_PREVIEWSTDOUT}" chafa --colors 16 --symbols=vhalf --bg="#000000" --"${1}"
    p  "${EXIT_PREVIEWSTDOUT}" sh -c 'exiftool -- "${1}"; chafa -f symbols "${1}"' _ "${1}"

  # Video and audio
  ;; video/* | audio/* | application/octet-stream)
    t  "${EXIT_NOPREVIEW}" mpv --vo=tct "${1}"
    g  "${EXIT_NOPREVIEW}" mpv "${1}"
    p  "${EXIT_NOPREVIEW}" exiftool "${1}"
    #p  "${EXIT_NOPREVIEW}" mediainfo "${1}"
    # TODO: thumbnail preview
  esac
}

################################################################################
# Adding true at the end to protect and short-circuit if statements
print_or_run() {
  exit_code="${1}"
  shift 1
  if "${FLAG_DRYRUN}"; then
    printf "${HANDLE_TYPE}: " >&2
    for x in "$@"; do
      printf %s " " >&2
      printf %s "${x}" | eval_escape >&2
    done
    printf \\n >&2
  else
    printf %s\\n "Opening/Launching ${HANDLE_TYPE}" "$*" >&2
    "$@"
  fi
  exit "${exit_code}"
}

print_or_launch() {
  exit_code="${1}"
  shift 1
  if "${FLAG_DRYRUN}"; then
    printf %s\\n "yo: $@"
    printf "${HANDLE_TYPE}: setsid" >&2
    for x in "$@"; do
      printf %s " " >&2
      printf %s "${x}" | eval_escape >&2
    done
    printf %s\\n >&2
  else
    printf %s\\n "Opening/Launching ${HANDLE_TYPE}" "$*" >&2
    setsid "$@" & #>/dev/null 2>&1&
  fi
  exit "${exit_code}"
}

et() { [ "${COMMAND}" = "${CMD_EDIT_TERM}" ] && print_or_run "$@"; }
eg() { [ "${COMMAND}" = "${CMD_EDIT_GUI}" ]  && print_or_launch "$@"; }
t()  { [ "${COMMAND}" = "${CMD_TERMINAL}" ]  && print_or_run "$@"; }
g()  { [ "${COMMAND}" = "${CMD_GUI}" ]       && print_or_launch "$@"; }
p()  { [ "${COMMAND}" = "${CMD_PREVIEW}" ]   && print_or_run "$@"; }

# Helpers
eval_escape() { <&0 sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"; }

main "$@"
