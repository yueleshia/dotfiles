#run: nickel export % --field text --format raw

let dirs = (import "../../profiles.ncl").current_profile.named_directories in

{ executable = false, text = m%"
# Seems to refresh the config everytime you run the `lf` client
#https://github.com/gokcehan/lf
#https://godoc.org/github.com/gokcehan/lf

# $f  : file under cursor
# $fs : selected file list, seperated by {filesep}
# $fx : $fs, but includes $f if no files are selected

# ':' means lf commands
# '%' means ??, redirect STDOUT to lf echoerr message?
# '$' means shell commands
# '!' means run shell command, see main screen for terminal, and do a `read -r`

set shell sh
set shellopts '-eu'  # '-e' exit on error, '-u' error on unset variables
set previewer ~/.config/scripts/preview.sh

# All pathnames seem to be given as absolute paths, thus
set filesep "\n/./"  # Make pathnames unique (www.etalabs.net/sh_tricks.html)
set ifs "\n"        # Sets ${IFS} for shell commands
set scrolloff 10    # Scroll offset, leave space at top/bottom of screen
set hidden      true
set icons       true

################################################################################
# Overwite default commands

# Commands
cmd open ${{
  notify.sh "Use e, o, or O. Edit this if you ever need to open multiple files at once."
#  mimetype() { file --mime-type --brief "$1"; }
#  NEWLINE='
#'
#  case "$( mimetype "${f}" )" in
#    text/troff*)  man ./ "${f}" ;;
#    text/* ) "${EDITOR}" "${f}" ;;
#    image/* )
#      dir="$( dirname "$f"; printf a )"; dir="${dir%?a}"
#      for file in "${dir}"/* "${dir}"/.[!.]* "${dir}"/..?*; do
#        [ ! -e "${file}" ] && continue
#        # Skip files with newlines
#        [ "${file}" != "${file##*"${NEWLINE}"*}" ] && continue
#        # Skip non-images
#        case "$( mimetype "${file}" )" in image/* ) ;; *) continue ;; esac
#
#        printf %s\\n "${file}"
#      done | setsid sxiv -ai >/dev/null 2>&1& ;;
#
#    *) printf %s "${fx}" | split-as-args.pl '\n/\./' '/' handle.sh gui --file ;;
#  esac
}}

# rename current file without overwrite
cmd rename %[ -e "${1}" ] && printf %s "File '${1}' exists" || mv -- "${f}" "${1}"
cmd jumpto $lf -remote "send ${id} cd '$( namedpath.sh interactive )'"
cmd delete %printf %s "${fx}" | split-as-args.pl '\n/\./' '/' trash
cmd prompt-rename ${{
   # `printf a` preserves the newline dash/bash strip in during `$( ... )`
   name="$( basename "${f}"; printf a )"; name="${name%?a}"
   newline="$( printf \\na )"; newline="${newline%a}"
   if [ "${name}" != "${name#*"${newline}"}" ]; then
     lf -remote "send ${id} echoerr Contains newline(s), use 'R' instead"
   else
     single_line="$( printf %s\\n "${name}" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/" )"
     lf -remote "send ${id} push :rename<space>${single_line}"
   fi
}}

# Test
map T ${{
  notify.sh "$(
    printf %s\\n \
      "f:  |$f|" \
      "fs: |$fs|" \
      "fx: |$fx|" \
    | tee /dev/stderr
  )"
}}

# Bindings
map <esc> :clear;unselect;reload
map e $hx "$f"
map E $vim "$f"
map R prompt-rename
map T delete
# Prepend '/.' since ${filesep} acts like a join
map <c-R> $batch-rename.sh --relative-path-to '.' --direct "/.${fx}"
map o $handle.sh terminal --file "${f}"
map O &handle.sh gui --file "${f}"
map D $rm -rf "$f"
map w $clipboard.sh -w "$f"
# This cannot deal with files with newlines
map L $for a in $( lf -remote load | sed -e '1d' ); do ln -s "$a" ./; done
#map <c-l> $handle.sh --file --gui "${f}"
map <enter> shell  # enter shell
map X $aunpack "${f}"
#map Y copyto
map c jumpto
#map M moveto

"% }
#
## Copy/Move to a named directory
#cmd copyto ${{
#  destination="$( namedpath.sh -i )" || exit "$?"
#  [ -d "${destination}" ]  || exit 1
#
#  printf %s "${fx}" | split-as-args.pl '\n/\./' '' sh -c '
#    destination="${1}"; shift 1
#    for f in "$@"; do
#      name="${f##*/}"
#      if [ -e "${destination}/${name}" ]
#        then notify.sh "The destination \"${destination}/${name}\" already exists"
#        else cp -r -- "${f}" "${destination}/${name}"
#      fi
#    done
#  ' _ "${destination}"
#
#  notify.sh "📋 File(s) copied to '${destination}'"
#}}
#
#cmd moveto ${{
#  destination="$( namedpath.sh -i )" || exit "$?"
#  [ -d "${destination}" ]  || exit 1
#  count="$( printf %s "${fx}" | split-as-args.pl '\n/\./' '' sh -c 'printf %s $#' _ )"
#
#  printf %s "${fx}" | split-as-args.pl '\n/\./' '' sh -c '
#    destination="${1}"; shift 1
#    for f in "$@"; do
#      name="${f##*/}"
#      if [ -e "${destination}/${name}" ]
#        then notify.sh "The destination \"${destination}/${name}\" already exists"
#        else mv -- "${f}" "${destination}/${name}"
#      fi
#    done
#  ' _ "${destination}"
#
#  after="$( printf %s "${fx}" | split-as-args.pl '\n/\./' '' sh -c '
#    count=0
#    for f in "$@"; do [ -e "${f}" ] && count="$(( count + 1 ))"; done
#    printf %s "${count}"
#  ' _ )"
#
#  notify.sh "🚚 $(( count - after )) file(s) moved to '${destination}'. ${count} item(s) were selected."
#}}
