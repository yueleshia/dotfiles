#run: nickel export % --field text --format raw

{ executable = false, text = m%"
# Reload on startup and default reloads every 60 minutes

#auto-reload yes
#reload-time 60

history-limit 0

# Need cat otherwise python throws a pipe error
#external-url-viewer "urlscan -cdn | cat - | handle.sh -l -t"
external-url-viewer "uriscan.sh -lms - | handle.sh -t -l"

# Cannot have multiple keys for the same keybind
# Can only have Ctrl + capital letter
# pageup and pagedown bindings seem to interfere with macros
bind-key Y pb-download
bind-key U show-urls
bind-key ^U pageup
bind-key x delete-article
bind-key ^D pagedown
bind-key G end
bind-key g home
bind-key J next-feed articlelist
bind-key K prev-feed articlelist
bind-key H quit
bind-key j down
bind-key k up
bind-key l open
bind-key n next-unread
bind-key m toggle-article-read
bind-key N prev-unread
unbind-key v


color listnormal black white
color listfocus black yellow
color listnormal_unread white blue standout
color listfocus_unread white yellow bold
color info black green bold
# color article white default

# For some reason urlscan -r kills ${BROWSER} variable
#external-url-viewer "urlscan -cd -r 'handle.sh -l -t \"{}\"'"

######## start ~ automatically replaced by 'config-newsboat.sh' ########
# Default macro key is ,
# 'external-url-viewer' pipes to command
# 'browser' provides %u or provides it as first argument
external-url-viewer "uriscan -lms - | handle.sh"
browser "handle.sh t -l"

macro h set browser "config-newsboat.sh --list"; open-in-browser ; set browser "handle.sh t -l"
macro t set browser "notify.sh '%u'"; open-in-browser ; set browser "handle.sh t -l"
macro T set external-url-viewer "notify.sh -"; show-urls ; set external-url-viewer "uriscan -lms - | handle.sh"
macro n next-feed article-list ; next-unread
macro p prev-feed article-list ; prev-unread
macro v set browser "queue.sh youtube-dl --video"; open-in-browser ; set browser "handle.sh t -l"
macro a set browser "queue.sh youtube-dl --audio"; open-in-browser ; set browser "handle.sh t -l"
macro s set browser "queue.sh youtube-dl --video --subtitles"; open-in-browser ; set browser "handle.sh t -l"
macro c set browser "clipboard.sh --write '%u'"; open-in-browser ; set browser "handle.sh t -l"
macro C set external-url-viewer "uriscan.sh -lms - | clipboard.sh -w -"; show-urls ; set external-url-viewer "uriscan -lms - | handle.sh"
macro o set browser "handle.sh g -l '%u'"; open-in-browser ; set browser "handle.sh t -l"
macro O set external-url-viewer "uriscan.sh -lms - | handle.sh g -l -i"; show-urls ; set external-url-viewer "uriscan -lms - | handle.sh"
macro e set external-url-viewer "${EDITOR}"; show-urls ; set external-url-viewer "uriscan -lms - | handle.sh"
macro d set external-url-viewer "uriscan.sh -lms - | handle.sh d -l -i"; show-urls ; set external-url-viewer "uriscan -lms - | handle.sh"
macro E set browser "sh -c '${EDITOR} ${XDG_CONFIG_HOME}/newsboat/config'"; open-in-browser ; set browser "handle.sh t -l"

######## close ~ automatically replaced by 'config-newsboat.sh' ########

"% }
