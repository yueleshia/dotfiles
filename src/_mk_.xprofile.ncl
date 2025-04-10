#run: nickel export % --field text --format raw

{ executable = true, text = m%"
#!/bin/sh
# Defaults to runs when after you login via display manager (login screen)
# Also manually sourced from '.xinitrc'

# NixOS runs startx and graphical DMs from a different shell environment
. "$HOME/.profile"

[ -r "$HOME/.Xresources" ] && xrdb "$HOME/.Xresources"
#[ -r "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xdefaults"

# Launch dbus for fcitx and perhaps pulse audio
# https://fcitx-im.org/wiki/Configure_(Other)#Use_Slim_.28.7E.2F.xinitrc.29.2Fstartx
# https://nixos.wiki/wiki/Using_X_without_a_Display_Manager
[ -z "${DBUS_SESSION_BUS_ADDRESS}" ] \
  && eval "$( dbus-launch --sh-syntax --exit-with-session )"

# Export fcitx variables before running graphical programs
export    XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE=fcitx
export  QT_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
if command -v fcitx5 2>&1 >/dev/null; then
  fcitx5 -d  # Restart fcitx5
elif command -v fcitx 2>&1 >/dev/null; then
  fcitx -d  # Restart fcitx
fi
# This has to be run after X starts?
#xmodmap "${XDG_CONFIG_HOME}/rc/.Xmodmap"  # Swap CapsLock and ControlR


# Startup up stuff
# Ideally, I want pipewire and wireplumber to be run on tty startup, not
# Xorg startup, but cannot figure runit for Void
xbacklight -set 40&            # Screen brightness
x.sh set-wallpaper&            # Desktop Wallpaper
xcompmgr -c&                   # Window Transparency
dunst&                         # Notifications
#pipewire&                      # For Void, cannot figure out user sv
wireplumber&                   # Session manager for pipewire
# Need neither pipewire nor wireplumber for NixOS, but if you manually run one
# then you also need to run wireplubmer
#mpd&                           # For music playing
#sxhkd&                         # For hotkeys

"% }
