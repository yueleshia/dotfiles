#run: nickel export % --field text --format raw

{ executable = true, text = m%"
#!/usr/bin/env sh
# https://stackoverflow.com/questions/6429515
#stty -ixon -ixoff # Archaic with modern CPU/modem speeds. Reclaims C-q and C-s

# Because of the breaking across newlines, fish needs semicolons

alias    ab='abook --datafile "$HOME/.config/abook/addressbook"'
alias   bcb='browser.sh print bookmarks | clipboard.sh --write'
alias   bgl='browser.sh gui link'
alias   bgb='browser.sh gui bookmarks'
alias   bgs='browser.sh gui search'
alias   bml='browser.sh menu link'
alias   bmb='browser.sh menu bookmarks'
alias   bms='browser.sh menu search'
alias   btl='browser.sh terminal link'
alias   btb='browser.sh terminal bookmarks'
alias   bts='browser.sh terminal search'
alias   btm='btm --celsius --tree --color nord-light'
alias  cgph='cd_of sh -c '\''
  a="$( git rev-parse --show-toplevel; printf a )" || exit "$?"; a="${a%?a}"
  printf %s "${a}"
'\'' _'
alias    ct='cd_of sh -c '\''
  printf %s "$( tmux display-message -F "#{pane_current_path}" -p -t "$1" )"
'\'' _'  # Change to same directory as another tmux pane
alias    cw='cd_of sh -c '\''
  printf %s "$( dirname "$( command -v "$1" )" )"
'\'' _'
alias     d='sdcv'
alias    da='podman attach'
alias    dr='podman run -it --rm'
alias  diso='dd status=progress conv=fdatasync'

alias    dc='sdcv --data-dir $STARDICT_DATA_DIR/ca'
alias  dcsa='sh -c '\''docker start  "${1}"; docker attach "${1}"'\'' _'
alias    de='sdcv --data-dir $STARDICT_DATA_DIR/en'
alias    dj='sdcv --data-dir $STARDICT_DATA_DIR/jp'
alias   dja='sdcv --data-dir $STARDICT_DATA_DIR/jpa'
alias   djo='sdcv --data-dir $STARDICT_DATA_DIR/jpo'
alias    dk='sdcv --data-dir $STARDICT_DATA_DIR/ko'
alias   dkj='sdcv --data-dir $STARDICT_DATA_DIR/kanji'
alias    dw='sdcv --data-dir $STARDICT_DATA_DIR/wy'
alias    dz='sdcv --data-dir $STARDICT_DATA_DIR/zh'
alias   dza='sdcv --data-dir $STARDICT_DATA_DIR/zha'

alias   env='printf %s\\n "use /usr/bin/env. Protect env secrets"'
alias    eb='browser.sh edit bookmarks'
alias    ee='browser.sh edit search'
alias    es='browser.sh edit search'
alias     g='git.sh'
alias    ga='git add'
alias   gap='git add --patch'
#alias    gc='git commit --gpg-sign="$( gpg.sh )" --message'
#alias   gca='git commit --gpg-sign="$( gpg.sh )" --amend'
alias    gc='git commit --message'
alias   gca='git commit --amend'
alias   gdc='git diff --word-diff=color --word-diff-regex=.'
alias   gdl='git diff --color-moved=plain'
alias   gdw='git diff --word-diff=color'
alias    gf='git fetch'
alias    gn='git clone --recursive'  # For submodules
alias   glg="git log --graph --abbrev-commit --decorate --oneline"
alias   glf='git log --follow'
alias glsst="git log | grep git-subtree-dir | sed 's/.*: //'"
alias    gp='git push --recurse-submodules=on-demand'
alias   gpf='git push --recurse-submodules=on-demand --force-with-lease'
alias   grc='sh -c '\''  # Revision count
  branch="${1:-"$( git branch | grep "^\\*" | cut -d " " -f 2 )"}"
  git rev-list --count "${branch}"
'\'' _'
alias    gs='git status'
alias  gssh='git remote set-url origin "$( git remote get-url origin | sed "s|https://github.com/|git@github.com:|" )"'
#alias  gcb='sh -c "
#  git checkout -b \"$1\"
#  git submodule foreach '\''git checkout -b \"$1\"'\''
#" _'
#alias    gu='git submodule update --remote --merge'
alias    gw='git worktree'
alias     l='eza --color=auto --group-directories-first  -h'
alias    la='eza --color=auto --group-directories-first  --sort=modified -rha'
alias   lal='eza --color=auto --group-directories-first  --sort=modified -rhal'
alias    ll='eza --color=auto --group-directories-first  --sort=modified -rhl'
alias   lla='eza --color=auto --group-directories-first  -ha'
alias  llal='eza --color=auto --group-directories-first  -hal'
# With `sed` can use escapes like "\n" in filenames
alias   mkf='sh -c '\''for x in "$@"; do
  [ "$1" != "${1%%*|*}" ] && { echo "Do not use \"|\" in file name"; exit 1; };
  name="$( printf \\n | sed "s|^|$x|"; printf a )"; name="${name%?a}";
  touch -- "${name}";
  chmod 644 -- "${name}";
done'\'' _'
alias   mks='sh -c '\''for x in "$@"; do
  [ "$1" != "${1#*|*}" ] && { echo "Do not use \"|\" in file name"; exit 1; };
  name="$(printf \\n | sed "s|^|$x|"; printf a)"; name="${name%?a}";
  touch -- "${name}";
  chmod 755 -- "${name}";
done'\'' _'
alias    mt='file --dereference --brief --mime-type --'
alias  mnta='sh -c '\''
  [ "$#" = 0 ] && { echo "mnta <num> <path>"; simple-mtpfs -l; exit 1; }
  simple-mtpfs -l | grep -q "^$1" || { echo "Device not found"; exit 1; };
  [ -d "$2" ] || { printf %s\\n "Invalid directory"; exit 1; };
  simple-mtpfs --device "$1" "$2";
'\'' _'  #chown "$( id -u ):$( id -g )" "$2"
alias  mntu='sh -c '\''
  [ "$#" = 0 ] && { echo "mntu <sd??> <path>"; lsblk; exit 1; }
  [ -e "/dev/$1" ] || { printf %s\\n "Device not found"; exit 1; };
  [ -d "$2" ] || { printf %s\\n "Invalid directory"; exit 1; };
  sudo mount -o "uid=$( id -u ),gid=$( id -g )" "/dev/$1" -- "$2";
'\'' _'
alias  mntn='sh -c '\''
  [ "$#" = 0 ] && { echo "mntu <sd??> <path>"; lsblk; exit 1; }
  [ -e "/dev/$1" ] || { printf %s\\n "Device not found"; exit 1; };
  [ -d "$2" ] || { printf %s\\n "Invalid directory"; exit 1; };
  sudo mount -t ntfs -o "uid=$( id -u),gid=$( id -g ),rw,auto,user,fmask=0133,dmask=0000" "/dev/$1" -- "$2";
'\'' _'
alias  nixc='sudo $EDITOR /etc/nixos/configuration.nix'
alias  nixd='sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 30d'
alias  nixl='nix-store -q --references /run/current-system/sw \
  | sed "s/^[^-]*-//"'
alias  nixr='sudo nixos-rebuild switch'
alias  nixs='nix --extra-experimental-features "nix-command flakes" search nixpkgs'
alias    pm='package-manager.sh'
alias     r='trash'
alias  rgpg='gpgconf --kill gpg-agent; gpg-connect-agent relodagent /bye'
#alias  rrc=''  # In individual rc files, reminder to not re-alias this
alias    rp='pass show refresh'
alias    rx='xrdb ~/.Xresources'
alias    od='handle.sh d --'
alias    oe='handle.sh e --'
alias    og='handle.sh g --'
alias    op='handle.sh v --'
alias    ot='handle.sh t --'
alias    tm='arecord -vvv -f dat /dev/null' # Multiple mics?
alias    tf='terraform'
alias    tg='terragrunt'
alias     v='$EDITOR'

#alias     e='emacs-sandbox.sh --user-dir "$EMACSINIT" -P -O'
#alias     e='emacs-sandbox.sh --user-dir ~/.config/emacs2 -P -O'
#alias   rhk='pkill -USR1 sxhkd; i3-msg reload'  # `sxhkd` updates on usr1 signal
#alias     t='tmux.sh'
#alias     w='weather.sh'

# Enable aliases in sudo commands
alias  nohup='nohup '
alias   sudo='sudo '
alias setsid='setsid '

alias c='cd_of sh -c '\''
  if [ -z "$1" ]; then
    namedpath.sh interactive;
  else
    namedpath.sh path "$1";
  fi
'\'' _'

# Need to `tac | rev` in case
#alias f='cd_of sh -c '\''
#  eval "set -- $(sh -c "lf >/dev/tty" 2>&1 | tac | rev)"
#  a="$(printf %s\\n "$1" | tac | rev; printf a)"; a="${a%?a}"
#  printf %s "$a"
#  '\'' _; \
#'

# Shell removes the EOF character from `cat` on assignment I believe
alias f='cd_of sh -c '\''
  tmp="$(mktemp -p "${TMPDIR:-/tmp}")";
  trap "rm \"${tmp}\"" EXIT;
  lf -last-dir-path="${tmp}" >&2;
  b="$(cat "${tmp}"; printf a)"; b="${b%a}";
  printf %s\\n "$b" >&2;
  printf %s "$b";
'\'' _'

#ffmpeg -i 'input' -1-6.mp4 -vn -acodec copy 'output'

# Switch Escape and RControl, have this enable in '/etc/sudoers' `visudo`
alias swapctrl='sudo loadkeys "$XDG_CONFIG_HOME/rc/remap-caps-rctrl.map"'
# Android has no sudo
alias updateman='sh -c "sudo -V >/dev/null 2>&1" \
  && sudo makewhatis "$PREFIX/usr/share/man" \
  || makewhatis "/usr/share/man"
'
alias list-path='printf %s\\n "$PATH" | tr ":" "\n" | sort'
alias list-users='cat /etc/passwd'
alias list-groups='cat /etc/group'

# -i list all Internet and x.25 network files
# -n prevents conversion of network numbers to host names (DNS translation)
# -l prevents conversion of user id numbers to login names
# -P prevents conversion of port numbers to port names
uname -o | grep -q 'GNU/Linux' && alias list-open-ports='lsof -i -nlP \
  | awk "{print \$9, \$8, \$1}" | sed "s/.*://" | sort -u'
uname -o | grep -q 'Android' && alias list-open-ports='lsof -i -nlP'
alias list-imes='sed -n "/^EnabledIMList=/{ s/^.*=//p; }" \
  $XDG_CONFIG_HOME/fcitx/profile \
  | awk -v RS="," -v FS=":" "(\$2 ~ /True/){ print \$1; }"'
#alias pipugradeall='python -m pip install --upgrade $(
#  python -m pip list --outdated | awk "(NR > 2){ print \$0;}")'
alias rimeinstall='c i; rime_frontend=fcitx-rime bash /rime-plum/rime-install'

"% }
