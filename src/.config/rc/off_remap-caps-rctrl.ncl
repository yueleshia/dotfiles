#run: nickel export % --field text --format raw

# I do this on the keyboard firmware layer
# This only works when X server is up so does not work for linux TTY (alt+ctrl+1)
# Also do not have to learn a different keyboard layout, when this is unsupported
{ executable = false, text = m%"
keycode 58 = Control
keycode 97 = Caps_Lock

"% }
