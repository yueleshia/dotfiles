#run: nickel export % --field text --format raw

{ executable = false, text = m%"
# help page: https://streamlink.github.io/cli.html

# Player options
player=mpv --cache 2048 --ontop --no-border --force-window --autofit=500x280 --geometry=-15-60
# player=mpv --cache 2048
player-no-close

# I have no idea why default-stream refuses to work with twitch-curses
# but works with the cli of streamlink, so using storing excludes instead
#default-stream="360p,480p,medium,low,best"
#default-stream=360p,480p,medium,low,best
stream-sorting-excludes=>=480p

"% }
