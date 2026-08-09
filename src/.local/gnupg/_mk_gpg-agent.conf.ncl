#run: nickel export % --field text --format raw

let dirs = (import "../../profiles.ncl").current_profile.named_directories in

{ executable = false, text = m%"
default-cache-ttl 500
pinentry-program %{dirs.h}/.nix-profile/bin/pinentry-curses

"% }
