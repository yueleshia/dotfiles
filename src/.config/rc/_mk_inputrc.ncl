#run: nickel export % --field text --format raw

{ executable = false, text = m%"
# Think about how this affects termux
#$include /etc/inputrc

# Set colours for tab completion
set colored-stats on

# Do not bell on tab-completion
set bell-style none

# The common prefix of all completion suggestions is shown in a different color
set colored-completion-prefix on

# Partially complete word and show all combinations
#set show-all-if-ambiguous on
set show-all-if-unmodified on

# Cycle backward: Shift-Tab
"\e[Z": menu-complete-backward

"% }
