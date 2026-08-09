#!/usr/bin/env sh

name="$( basename "$0"; printf a )"; name="${name%?a}"

show_help() {
  <<EOF cat - >&2
SYNOPSIS
  ${name}

DESCRIPTION
  

OPTIONS
  --
    Special argument that prevents all following arguments from being
    intepreted as options.
EOF
}
ME="mw"
PREFIX="${PREFIX:-"$(
  case "$( uname -o )" in
    *Linux)   printf '/usr' ;;
    Android)  printf '/data/data/' ;;
    *)        printf '/usr/local' ;;
  esac
)"}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
MUTTDIR="${HOME}/.config/mutt"        # Main mutt config location
ACCDIR="${MUTTDIR}/accounts"          # Directory for account settings
MAILDIR="${HOME}/.local/share/mail"   # Location of mail storage
EMAILRE='.\+@.\+\..\+'                # Regex to confirm valid email address
ID_REGEXP='^[a-z_][a-z0-9_-]*$'
#16BIT_REGEXP="$( printf %s \
#  '^[1-5]\?[0-9]\{1,4\}$\|' \
#  '^6[0-4][0-9]\{3\}$\|' \
#  '^65[0-4][0-9][0-9]$\|' \
#  '^655[0-2][0-9]$\|' \
#  '^6553[0-5]$' \
#)"
#MUTTSHARE="${PREFIX}/share/mutt-wizard"
MUTTSHARE="${HOME}/dotfiles/share/mw"
IMAP_CSV="${MUTTSHARE}/imap.csv"
POP_CSV="${MUTTSHARE}/pop.csv"
#MBSYNCRC="${HOME}/.mbsyncrc"
#MWCONFIG="${MUTTSHARE}/mutt-wizard.mutt"
CACHEDIR="${HOME}/.cache/mutt-wizard"
MUTTRC="${MUTTDIR}/muttrc"
#MSMTPRC="${HOME}/.config/msmtp/config"

MSMTP_DIR="${XDG_CONFIG_HOME}/msmtp"
MSMTP_ACCDIR="${MSMTP_DIR}/accounts"

ENUM_IMAP="1"
ENUM_POP="2"
ENUM_ONLINE="3"

RED='\001\033[31m\002'
GREEN='\001\033[32m\002'
YELLOW='\001\033[33m\002'
BLUE='\001\033[34m\002'
MAGENTA='\001\033[35m\002'
CYAN='\001\033[36m\002'
CLEAR='\001\033[0m\002'

# Handles single character-options joining (eg. pacman -Syu)
main() {
  case "$( if [ "$#" = 0 ];
    then prompt_test 'ls\|add\|pass\|rm\|' "$(
      outln "${CYAN}ls${CLEAR}   - list accounts"
      outln "${CYAN}add${CLEAR}  - add an account"
      outln "${CYAN}pass${CLEAR} - change the password"
      outln "${CYAN}open${CLEAR} - open"
      outln "${CYAN}rm${CLEAR}   - delete an account"
      outln "Enter one of the options: ${CYAN}" )"
    else printf %s "$1"
  fi )" in
    add)   add_account 1 ;;
    pass)  pass edit "${ME}-$( pick "$( list_configs pass )" )" ;;
    rm)    echo WIP ;;
    open)  neomutt -F "${ACCDIR}/$( pick "$( list_configs mutt )" ).mutt" ;;
    ls)
      pass="$( list_configs pass )"
      for id in $( list_configs id ); do
        pcln "For the account ID ${CYAN}$i${CLEAR}"
        if outln "${pass}" | grep -q "^${ME}-$i$"
          then pcln "\`pass\` entry ${GREEN}found${CLEAR}"
          else pcln "\`pass\` entry ${RED}not found${CLEAR}"
        fi
      done ;;
    *)  show_help; exit 1 ;;
  esac
}

list_configs() {
  case "$1" in
    id)  list_configs mutt | sed -n "/${ID_REGEXP}/p" ;;
    mutt)
      for i in "${ACCDIR}"/*.mutt; do
        [ -e "$i" ] && i="${i#"${ACCDIR}/"}" && outln "${i%.mutt}"
      done ;;
    pass)
      for p in "${PASSWORD_STORE_DIR:-~/.password-store}/${ME}"-*.gpg; do
        # Need the test as wildcards evaluate to plain-text if nothing found
        [ -e "${p}" ] && p="${p##*/${ME}-}" && outln "${p%.gpg}"
      done | grep "${ID_REGEXP}" ;;
    *)  die 1 'DEV' "list() -- invalid option"
  esac
}

add_account() {
  # In normal use, $# should be 0 (used for dev testing)
  case "$( if [ "$#" = 0 ]
    then prompt_test '1\|2\|3\|4\|5' "$( outln \
      'Pick a number: ' \
      '1) Mutt (IMAP) - Online built-in IMAP feature of mutt' \
      '2) isync (IMAP) - Uses isync/mbsync to sync via IMAP' \
      '3) Mutt (POP) - Uses' \
      '4) getmail (IMAP) - No syncing, just store mail locally via IMAP4' \
      '5) getmail (POP) - No syncing, just store mail locally via POP3' \
    )"
    else outln "$1"
  fi )" in
    1) ask_info "${ENUM_ONLINE}" ;;
    2) echo isync;;
    3) ask_info "${ENUM_POP}" ;;
    4) echo getmail;;
    5) echo getmail;;
  esac
}


ask_server() {
  pcln "Your email domain is not in ${ME}'s database yet. Please type in your" \
    "server information. You can find this by searching the internet."
  pcln "${CLEAR}IMAP server? (excluding the port number)"
  pc "${CYAN}"; read -r inserver; pc "${CLEAR}"
  pcln 'IMAP port number? (Usually 993 with TLS/SSL)'
  pc "${CYAN}"; read -r inport; pc "${CLEAR}"
  pcln 'SMTP server? (excluding the port number)'
  pc "${CYAN}"; read -r smtpserver; pc "${CLEAR}"
  pcln 'SMTP port number? (Usually 587 or 465)'
  pc "${CYAN}"; read -r smtpport; pc "${CLEAR}"
  #outln "Great! If you want to be helpful, copy the line below and you can"
  #  "add it to the 'domains.csv' file on Github. This will make things" \
  #  'easier for others who use your email provider.' \
  #  '' \
  #  "${domain},${inserver},${inport},${smtpserver},${smtpport}" \
  #  '' \
  #  "Although be sure to test to see if these settings work first! ;-)"
  outln "${inserver},${inport},${smtpserver},${smtpport}"
}


ask_info() {
  protocol="$1"
  fulladdr="$( prompt_test "${EMAILRE}" \
    "Full ${BLUE}email address${CLEAR}: " \
    "Not a valid ${RED}email address${CLEAR}. Full Email Address: "
  )"
  domain="${fulladdr##*@}"
  servercsv="$( if \
    [ "${protocol}" = "${ENUM_IMAP}" ] \
    || [ "${protocol}" = "${ENUM_ONLINE}" ]
      then outln "${IMAP_CSV}"
      else outln "${POP_CSV}"
    fi
  )"
  serverinfo="$( grep -e "^${domain}" "${servercsv}" )"

  pc "Searching for ${GREEN}${domain}${CLEAR} in " \
    "${BLUE}'${servercsv##*/}'${CLEAR}..."
  pcln

  if [ -z "${serverinfo}" ]; then
    read_from "$( ask_server "${protocol}" )" ',' inserver inport smtp sport
  else
    read_from "${serverinfo}" ',' service inserver inport smtp sport
    pcln '' \
      "${GREEN}Congrats!${CLEAR} Server info has automatically been found!" \
      "${BLUE}IMAP server${CLEAR}: ${inserver}" \
      "${BLUE}IMAP port${CLEAR}:   ${inport}" \
      "${BLUE}SMTP server${CLEAR}: ${smtp}" \
      "${BLUE}SMTP port${CLEAR}:   ${sport}" \
      '' \
      'This data will be used by the wizard.' \
      ''
    case "${service}" in
      gmail.com)
        pcln "${RED}REMEMBER: Gmail users must enable \"less secure\"" \
          "(third-party) applications first for the sync to work:" \
          "https://support.google.com/accounts/answer/6010255${CLEAR}"
        ;;
      protonmail.ch|protonmail.com|pm.me)
        pcln \
          "${RED}REMEMBER: Protonmail users must install and configure" \
          "Protonmail Bridge first for the sync to work:" \
          "https://protonmail.com/bridge${CLEAR}"
        ssltype="None"
        ;;
    esac
  fi
  realname="$( prompt_test '.*' "$(
    out "Enter name for this account (appears in the 'from' header)"
    outln
    out "${BLUE}Full name: ${CLEAR}" \
  )" )"
  id="$( prompt_test "${ID_REGEXP}" "$(
      out "Enter a short, ${YELLOW}one-word identifier${CLEAR} for this " \
        "email account that will distinguish it from other accounts added. " \
        " Does not affect your emails, only the names of setting files, etc."
      outln
      out "${BLUE}Account ID${CLEAR}: "
    )" "$(
      out "${RED}Try again${CLEAR}. Pick a nickname that is only one word " \
        "including lowercase letters and _ or - and that you have ${RED}" \
        "${RED}not${CLEAR} used before."
      outln
      out "${BLUE}Account name${CLEAR}: "
    )"
  )"
  #pcln "If your account has a special username different from your address, insert it now. Otherwise leave this prompt totally blank.\\n\033[34mMost accounts will not have a separate login, so you should probably leave this blank.\033[0m\\n\tLogin(?): \033[36m"
  #read -r login
  #printf "\033[0m"
  #[ -z "$login" ] && login="$fulladdr"
  login="${fulladdr}"


 for x in "/etc/ssl/certs/ca-certificates.crt" \
   "/etc/pki/tls/certs/ca-bundle.crt" \
   "/etc/ssl/ca-bundle.pem" \
   "/etc/pki/tls/cacert.pem" \
   "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem" \
   "/etc/ssl/cert.pem" \
   "/usr/local/share/ca-certificates/"
 do
   [ -f "$x" ] && sslcert="$x" && break
 done || {
   pcln "CA Certificate not found." \
     "Please install one or link it to /etc/ssl/certs/ca-certificates.crt"
   exit 1
 }

msmtp="defaults
auth on
tls on
tls_trust_file ${sslcert}
logfile \"${MSMTP_DIR}/msmtp.log\"

account ${id}
host ${smtp}
port ${sport}
from ${fulladdr}
user ${login}
passwordeval \"pass ${ME}-${id}\"
$( [ "${sport}" = 465 ] && out "tls_starttls off" )

account default : ${id}
"

mbsync_profile="IMAPStore ${id}-remote
Host ${inserver}
Port ${inport}
User ${login}
PassCmd \"pass ${ME}-${id}\"
$( if false  # Protonmail
  then out "SSLType None"
  else out "SSLType IMAPS"
fi )
CertificateFile ${sslcert}

MaildirStore ${id}-local
Subfolders Verbatim
Path ~/.local/share/mail/${id}/
Inbox ~/.local/share/mail/${id}/INBOX
Flatten .

Channel ${id}
Expunge Both
Master :${id}-remote:
Slave :${id}-local:
Patterns * !\"[Gmail]/All Mail\"
Create Both
SyncState *
MaxMessages $maxmes
# End profile
"

mutt="# vim: filetype=muttrc
# muttrc file for account ${id}
source \"${MUTTRC}\"
set realname = \"${realname}\"
set from = \"${fulladdr}\"
$( if [ "${protocol}" = "${ENUM_ONLINE}" ]
  then out "set folder = \"imaps://\$from@${inserver}:${inport}\""
  else out "set folder = \"${maildir}/${id}\""
fi )
$( if [ "${protocol}" = "${ENUM_IMAP}" ] || [ "${protocol}" = "${ENUM_ONLINE}" ]
  then out "set imap_pass = \"\`pass show '${ME}-${id}'\`\""
  else out "set pop_pass = \"\`pass show '${ME}-${id}'\`\""
fi )
# By using msmtp, can avoid folder-hook to set smtp settings in mutt
# Also some servers do not agree with smtps links with base mutt
set sendmail = \"msmtp -C ${MSMTP_ACCDIR}/${id}.msmtprc\"
$(#set smtp_url = \"smtps://\$from@${smtp}:${sport}\"
#set smtp_pass = \"\`pass show '${ME}-${id}'\`\"
)
#set header_cache = ${CACHEDIR}/${id}/headers
#set message_cachedir = ${CACHEDIR}/${id}/bodies

set mbox_type = Maildir
$( [ "${protocol}" = "${ENUM_ONLINE}" ] && outln \
  "set ssl_starttls = yes" \
  "set ssl_force_tls = yes" \
)

$( [ "${protocol}" = "${ENUM_ONLINE}" ] && out "set spoolfile = +INBOX" )
unmailboxes *
"
  pcln '' "${CYAN}mutt profile${CLEAR}" "${mutt_profile}"

  # Password
  while :; do
    pass rm -f "${ME}-${id}" >/dev/null 2>&1
    pass insert "${ME}-${id}" && break
  done

  #[ -e "${ACCDIR}/${id}" ] && die 1 'FATAL' "${id} already exists"
  write_or_exit "${ACCDIR}/${id}.mutt" "${mutt}"
  write_or_exit "${MSMTP_ACCDIR}/${id}.msmtprc" "${msmtp}"
}

################################################################################
# IO Helpers

write_or_exit() {
  if [ -e "$1" ]; then
    pcln "'${RED}$1${CLEAR}' already exists!"
    pc "Overwrite (y/N): "; read -r input
    case "${input}" in
      y|Y)  ;;
      *)    exit 1 ;;
    esac
  fi
  mkdir -p "${1%/*}"
  out "$2" > "$1"
}


# Do not pipe to this to retain namespace
read_from() {
  first="$1"; shift 1
  separator="$1"; shift 1
  # Cannot pipe here either because of namespaces
  IFS="${separator}" read -r "$@" <<EOF
${first}
EOF
}

prompt_test() {
  pc "$2"; read -r value; pc "${CLEAR}"
  while outln "${value}" | grep -qve "$1"; do
    pc "${3:-"$2"}"; read -r value
    pc "${CLEAR}"
  done
  out "${value}"
}

pick() {
  msg="$(
    outln "$1" | awk '{ print "\'"${CYAN}"'" NR "\'"${CLEAR}"') " $0 }'
    out "Enter your choice: ${CYAN}"
  )"
  choice="$( prompt_test "$(
      outln "$1" | awk '
        (NR == 1){ printf("^1$"); }
        (NR > 1){ printf("%s", "\\|^" NR "$"); }
      '
    )" "${msg}" "$( outln "${RED}Invalid option${CLEAR}" "${msg}" )"
  )"
  outln "$1" | sed -n "${choice}p"
}


################################################################################
# Semantic Shell Helpers
pc() { printf %b "$@" >/dev/tty; }
pcln() { printf %b\\n "$@" >/dev/tty; }
out() { printf %s "$@"; }
outln() { printf %s\\n "$@"; }
outerr() { printf %s\\n "$@" >&2; }
die() { c="$1"; outerr "$2: '${name}' -- $3"; shift 3; outerr "$@"; exit "$c"; }

main "$@"
