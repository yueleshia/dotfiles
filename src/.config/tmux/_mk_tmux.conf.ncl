#run: nickel export % --field text --format raw

{ executable = false, text = m%"
# For adapating to SSH host in title window
# In general I prefer more obvious-to-a-layman setting names
# Everything but set-option = set-window-option will be more verbose

# C-b is used in emacs for basic movement
unbind-key C-b
set -g prefix 'C-]'
bind-key 'C-]' send-prefix

# -s server option (not session), -g global option (not window)
set-option -sa terminal-overrides ",xterm*:Tc" # Fix colours
set-option -sg escape-time 30      # ms, otherwise would need to hit Esc twice
set-option -g automatic-rename on  # Default on, change window name
set-option -g automatic-rename-format \
  "#{pane_current_command} (#{pane_pid}) [#{pane_id}]"
set-option -g set-titles off       # X title, my window manager hides this anyway
set-option -g display-time 5000    # Status bar highlight notification
set-option -g history-limit 10000  # Default 2000
set-option -g monitor-activity on  # Enable window highlight notification

#set-option -g default-terminal "tmux-256color"  # Running into issues
#set-option -ga terminal-overrides  ",*256col*:Tc"

set-option -g mouse on             # Enable rebinding of mouse keys
set-option -g status-keys emacs    # Command line mode to use emacs keybinds
set-option -g mode-keys vi         # Copy mode to use vi keybinds
set-option -g focus-events on



################################################################################
# Copy mode buidings
bind-key C-[ copy-mode   # Solve IME problems (no menu, sending wrong keys)
bind-key -T copy-mode-vi C-q send-keys -X cancel  # Usually pressing Ctrl anyway

bind-key -T copy-mode-vi Escape send-keys -X cancel
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y \
  send-keys -X copy-pipe "clipboard.sh -w" \;\
  send-keys -X copy-selection \;\
  send-keys -X clear-selection

# Prevent end of drag event from cancelling copy mode
bind-key -T copy-mode-vi MouseDragEnd1Pane \
  send-keys -X copy-pipe "clipboard.sh -w"
bind-key -T copy-mode-vi MouseDragEnd1Pane \
  send-keys -X copy-pipe "clipboard.sh -w"


# Mouse options
# TODO: see if we can do without select-pane
bind-key -n WheelDownPane \
  if-shell -Ft= '#{alternate_on}' \
    'select-pane -M -t= ; send-keys down' \
    'copy-mode'
bind-key -n WheelUpPane \
  if-shell -Ft= '#{alternate_on}' \
    'select-pane -M -t= ; send-keys up' \
    'copy-mode'

# send down/up scrolls without affecting selection, so special case copy-mode
# Though should not be using mouse for selection anyway
#bind-key -T copy-mode-vi C-WheelDownPane \
#  send-key -X scroll-down \;\
#  send-key -X scroll-down \;\
#  send-key -X scroll-down \;\
#  send-key -X scroll-down
#bind-key -T copy-mode-vi C-WheelUpPane \
#  send-key -X scroll-up \;\
#  send-key -X scroll-up \;\
#  send-key -X scroll-up \;\
#  send-key -X scroll-up

##############################################################################
# Pane Management Hotkeys
bind-key v split-window -h
bind-key b split-window -v
bind-key c new-window -c "#{pane_current_path}"

bind-key H resize-pane -L 5
bind-key J resize-pane -D 5
bind-key K resize-pane -U 5
bind-key L resize-pane -R 5  # Replaces `switch-client -l`

bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R   # Replaces `last-window`
bind-key \; select-pane -R  # Replaces `last-pane`

# Alt+vim-arrow-keys without bind key to select panes
bind-key -n M-h select-pane -L
bind-key -n M-j select-pane -D
bind-key -n M-k select-pane -U
bind-key -n M-l select-pane -R

bind-key -n M-H resize-pane -L 5
bind-key -n M-J resize-pane -D 5
bind-key -n M-K resize-pane -U 5
bind-key -n M-L resize-pane -R 5
bind-key -n M-: resize-pane -R 5
bind-key -n "M-'" command-prompt -I "run-shell '"

bind-key -n C-M-n next-window
bind-key -n C-M-p previous-window

bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5
bind-key -n M-6 select-window -t 6
bind-key -n M-7 select-window -t 7
bind-key -n M-8 select-window -t 8
bind-key -n M-9 select-window -t 9
bind-key -n M-0 select-window -t 0


##############################################################################
# Clipboard
bind-key C-c run-shell "\
  clipboard.sh --read | clipboard.sh --clipboard tmux --write"
# If we it to clear the file clipboard
#bind-key C-c run-shell "clipboard.sh -x file --read \
  | { clipboard.sh --clipboard file --write ''; <&0 cat -; } \
  | clipboard.sh --write"
bind-key C-v run-shell 'tmux.sh insert-evaluate "clipboard.sh --read"'
#bind-key C-v run-shell 'tmux.sh insert-evaluate "clipboard.sh -x tmux --read"'

##############################################################################
# Other Ctrl shortcuts
bind-key C-E capture-pane \; new-window "tmux save-buffer - | ${EDITOR}"
bind-key C-e run-shell 'tmux.sh insert-evaluate " \
  <\"${HOME}/.config/emoji\" fzf | cut -d \" \" -f 1 \
"'
bind-key C-r source-file ~/.config/tmux/tmux.conf \; run-shell 'notify.sh "Reloaded tmux.conf"'
bind-key C-p run-shell 'select-pass.sh'

#bind-key C-U capture-pane \; new-window "tmux save-buffer - | \"${EDITOR}\""
bind-key C-U capture-pane \; new-window "tmux save-buffer - | w3m "
bind-key C-u capture-pane \; new-window \
  "tmux save-buffer - | uriscan.sh --links --stricter-urls - | \"${EDITOR}\""

# Insert emoji, both quoting styles work
#bind-key C-d run-shell 'tmux.sh insert-evaluate " \
#  <\"${DOTENVIRONMENT}/discord.csv\" fzf --delimiter=, --with-nth=1..-2 \
#  | cut -d \",\" -f 2 \
#"'

# Trying to run if in the GUI too
#bind-key C-n send-keys \
  'tmux move-pane -s "$TMUX_PANE" -t "$(tmux new-session -dP)"' \
  ' && tmux kill-pane -t 0' \
  ' && [ -n "${TERMINAL_EXECUTE}" ]' \
    ' && ${TERMINAL} tmux attach-session -t $TMUX_PANE' \
Enter

#bind-key C-f split-window -h \; send-keys '$TMUX_BROWSER searx.me' C-m Tab C-m
bind-key C-l send-keys 'ls -Altr --group-directories-first' Enter

# Search [b]ack to last prompt, prompt has an special unicode space
bind-key C-b copy-mode\; send-keys -X start-of-line\; \
  send-keys -X search-backward " "\; send-keys -X cursor-right

bind-key C-x kill-pane

# insert-evaluate passes the original pane_id as an argument
#bind-key -n M-Space run-shell 'tmux.sh insert-evaluate "autocomplete.sh -t"'

"% }
