#run: nickel export % --field text --format raw

{ executable = false, text = m%"
# i3 config file (v4)
#
# Please see http://i3wm.org/docs/userguide.html for a complete reference!

# I background all the process because of https://www.reddit.com/r/i3wm/comments/73m3mx/

for_window [class="^.*"] border pixel 3
gaps inner 10
gaps outer 5
set $mod Mod4
for_window [title="fullscreen_overlay"] floating enable
for_window [title="fullscreen_overlay"] border pixel 5
for_window [title="fullscreen_overlay"] fullscreen

# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod

# Startup
#exec_always --no-startup-id feh --bg-scale ~/.config/wallpaper.jpg &
##exec --no-startup-id compton --xrender-sync-fence --logpath /tmp/compton.log &
#exec --no-startup-id compton --xrender-sync-fence &


# Font for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
font pango:monospace 8
#font pango:DejaVu Sans Mono 8

set $up k
set $down j
set $left h
set $right l

################################################################################
# Manual Input
#bindsym $mod+Return exec --no-startup-id $term -e $tmux &
bindsym Mod4+d exec --no-startup-id "dmenu_run"
bindsym Mod4+Shift+q kill window

bindsym Mod4+Shift+f fullscreen toggle
bindsym Mod4+Shift+space focus mode_toggle
bindsym Mod4+r mode "M+r"
mode "M+r" {
  bindsym $mod+r reload
  bindsym $mod+q restart
  bindsym $left  resize shrink width 10 px or 10 ppt
  bindsym $down  resize grow height 10 px or 10 ppt
  bindsym $up    resize shrink height 10 px or 10 ppt
  bindsym $right resize grow width 10 px or 10 ppt

  # same bindings, but for the arrow keys
  bindsym Left   resize shrink width 10 px or 10 ppt
  bindsym Down   resize grow height 10 px or 10 ppt
  bindsym Up     resize shrink height 10 px or 10 ppt
  bindsym Right  resize grow width 10 px or 10 ppt

  bindsym Escape mode "default"
}
################################################################################


# change focus
bindsym Mod4+$left focus left
bindsym Mod4+$down focus down
bindsym Mod4+$up focus up
bindsym Mod4+$right focus right
bindsym Mod4+semicolon focus right

bindsym Mod4+Left focus left
bindsym Mod4+Down focus down
bindsym Mod4+Up focus up
bindsym Mod4+Right focus right



# move focused window
bindsym Mod4+Shift+$left move left
bindsym Mod4+Shift+$down move down
bindsym Mod4+Shift+$up move up
bindsym Mod4+Shift+$right move right
bindsym Mod4+Shift+semicolon move right

bindsym Mod4+Shift+Left move left
bindsym Mod4+Shift+Down move down
bindsym Mod4+Shift+Up move up
bindsym Mod4+Shift+Right move right


set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

# switch to workspace
bindsym Mod4+1 workspace number $ws1
bindsym Mod4+2 workspace number $ws2
bindsym Mod4+3 workspace number $ws3
bindsym Mod4+4 workspace number $ws4
bindsym Mod4+5 workspace number $ws5
bindsym Mod4+6 workspace number $ws6
bindsym Mod4+7 workspace number $ws7
bindsym Mod4+8 workspace number $ws8
bindsym Mod4+9 workspace number $ws9
bindsym Mod4+0 workspace number $ws10

# move focused container to workspace
bindsym Mod4+Shift+1 move container to workspace number $ws1
bindsym Mod4+Shift+2 move container to workspace number $ws2
bindsym Mod4+Shift+3 move container to workspace number $ws3
bindsym Mod4+Shift+4 move container to workspace number $ws4
bindsym Mod4+Shift+5 move container to workspace number $ws5
bindsym Mod4+Shift+6 move container to workspace number $ws6
bindsym Mod4+Shift+7 move container to workspace number $ws7
bindsym Mod4+Shift+8 move container to workspace number $ws8
bindsym Mod4+Shift+9 move container to workspace number $ws9
bindsym Mod4+Shift+0 move container to workspace number $ws10

# Start i3bar to display a workspace bar (plus the system information i3status
# finds out, if available)
bar {
  status_command exec statusbar-startrefresh.sh --i3
  bindsym --release button1 exec --no-startup-id statusbar-startrefresh.sh --i3
}

########## automatically generated begin ##########
bindsym Ctrl+Mod4+a mode "C+M+a"
bindsym Shift+Mod4+a exec --no-startup-id "shortcuts.sh 'shift super a'"; mode "default"
bindsym Mod4+c mode "M+c"
bindsym Mod4+g mode "M+g"
bindsym Ctrl+Shift+Mod4+q exec --no-startup-id "shortcuts.sh 'ctrl shift super q'"; mode "default"
bindsym Mod4+u mode "M+u"
bindsym Print exec --no-startup-id "shortcuts.sh 'Print'"; mode "default"
bindsym Mod4+space mode "M+space"
bindsym Shift+Mod4+Insert exec --no-startup-id "shortcuts.sh 'shift super Insert'"; mode "default"
bindsym Mod4+Return exec --no-startup-id "shortcuts.sh 'super Return'"; mode "default"
bindsym Mod1+Mod4+Return exec --no-startup-id "shortcuts.sh 'alt super Return'"; mode "default"
bindsym Mod1+Ctrl+Mod4+Return exec --no-startup-id "shortcuts.sh 'alt ctrl super Return'"; mode "default"
bindsym Shift+Mod4+Return exec --no-startup-id "shortcuts.sh 'shift super Return'"; mode "default"
bindsym Mod1+Shift+Mod4+Return exec --no-startup-id "shortcuts.sh 'alt shift super Return'"; mode "default"
bindsym Ctrl+Shift+Mod4+Return exec --no-startup-id "shortcuts.sh 'ctrl shift super Return'"; mode "default"
bindsym Mod1+Ctrl+Shift+Mod4+Return exec --no-startup-id "shortcuts.sh 'alt ctrl shift super Return'"; mode "default"
bindsym Mod4+BackSpace mode "M+BackSpace"
bindsym XF86MonBrightnessUp exec --no-startup-id "shortcuts.sh 'XF86MonBrightnessUp'"; mode "default"
bindsym XF86MonBrightnessDown exec --no-startup-id "shortcuts.sh 'XF86MonBrightnessDown'"; mode "default"

mode "C+M+a" {
  bindsym Mod4+Return exec --no-startup-id "shortcuts.sh 'ctrl super a ; super Return'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+c" {
  bindsym Mod4+b exec --no-startup-id "shortcuts.sh 'super c ; super b'"; mode "default"
  bindsym Mod4+c exec --no-startup-id "shortcuts.sh 'super c ; super c'"; mode "default"
  bindsym Mod4+e exec --no-startup-id "shortcuts.sh 'super c ; super e'"; mode "default"
  bindsym Mod4+g exec --no-startup-id "shortcuts.sh 'super c ; super g'"; mode "default"
  bindsym Mod4+s exec --no-startup-id "shortcuts.sh 'super c ; super s'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+g" {
  bindsym Mod4+a exec --no-startup-id "shortcuts.sh 'super g ; super a'"; mode "default"
  bindsym Mod4+b exec --no-startup-id "shortcuts.sh 'super g ; super b'"; mode "default"
  bindsym Mod4+e exec --no-startup-id "shortcuts.sh 'super g ; super e'"; mode "default"
  bindsym Mod4+g exec --no-startup-id "shortcuts.sh 'super g ; super g'"; mode "default"
  bindsym Mod4+s exec --no-startup-id "shortcuts.sh 'super g ; super s'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+u" {
  bindsym Mod4+e mode "M+u;M+e"
  bindsym Mod4+q mode "M+u;M+q"
  bindsym Mod4+r mode "M+u;M+r"
  bindsym Mod4+t mode "M+u;M+t"
  bindsym Mod4+w mode "M+u;M+w"
  bindsym Escape mode "default"
}

mode "M+space" {
  bindsym Mod4+a exec --no-startup-id "shortcuts.sh 'super space ; super a'"; mode "default"
  bindsym Mod4+e exec --no-startup-id "shortcuts.sh 'super space ; super e'"; mode "default"
  bindsym Mod4+m exec --no-startup-id "shortcuts.sh 'super space ; super m'"; mode "default"
  bindsym Mod4+n exec --no-startup-id "shortcuts.sh 'super space ; super n'"; mode "default"
  bindsym Mod4+s exec --no-startup-id "shortcuts.sh 'super space ; super s'"; mode "default"
  bindsym Mod4+w exec --no-startup-id "shortcuts.sh 'super space ; super w'"; mode "default"
  bindsym Mod4+z exec --no-startup-id "shortcuts.sh 'super space ; super z'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+BackSpace" {
  bindsym Mod4+e exec --no-startup-id "shortcuts.sh 'super BackSpace ; super e'"; mode "default"
  bindsym Mod4+q exec --no-startup-id "shortcuts.sh 'super BackSpace ; super q'"; mode "default"
  bindsym Mod4+r exec --no-startup-id "shortcuts.sh 'super BackSpace ; super r'"; mode "default"
  bindsym Mod4+t exec --no-startup-id "shortcuts.sh 'super BackSpace ; super t'"; mode "default"
  bindsym Mod4+w exec --no-startup-id "shortcuts.sh 'super BackSpace ; super w'"; mode "default"
  bindsym Mod4+BackSpace exec --no-startup-id "shortcuts.sh 'super BackSpace ; super BackSpace'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+u;M+e" {
  bindsym Mod4+e exec --no-startup-id "shortcuts.sh 'super u ; super e ; super e'"; mode "default"
  bindsym Mod4+q exec --no-startup-id "shortcuts.sh 'super u ; super e ; super q'"; mode "default"
  bindsym Mod4+w exec --no-startup-id "shortcuts.sh 'super u ; super e ; super w'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+u;M+q" {
  bindsym Mod4+e exec --no-startup-id "shortcuts.sh 'super u ; super q ; super e'"; mode "default"
  bindsym Mod4+q exec --no-startup-id "shortcuts.sh 'super u ; super q ; super q'"; mode "default"
  bindsym Mod4+w exec --no-startup-id "shortcuts.sh 'super u ; super q ; super w'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+u;M+r" {
  bindsym Mod4+e exec --no-startup-id "shortcuts.sh 'super u ; super r ; super e'"; mode "default"
  bindsym Mod4+q exec --no-startup-id "shortcuts.sh 'super u ; super r ; super q'"; mode "default"
  bindsym Mod4+w exec --no-startup-id "shortcuts.sh 'super u ; super r ; super w'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+u;M+t" {
  bindsym Mod4+q exec --no-startup-id "shortcuts.sh 'super u ; super t ; super q'"; mode "default"
  bindsym Escape mode "default"
}

mode "M+u;M+w" {
  bindsym Mod4+e exec --no-startup-id "shortcuts.sh 'super u ; super w ; super e'"; mode "default"
  bindsym Mod4+q exec --no-startup-id "shortcuts.sh 'super u ; super w ; super q'"; mode "default"
  bindsym Mod4+w exec --no-startup-id "shortcuts.sh 'super u ; super w ; super w'"; mode "default"
  bindsym Escape mode "default"
}

########## automatically generated close ##########

"% }
