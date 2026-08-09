#run: nickel export % --field text --format raw

let colours = import "../../meta/colours.ncl" in

{ executable = false, text = m%"
[colors.primary]
background        = "#%{colours.background}"
foreground        = "#%{colours.foreground}"
#dim_foreground    = ""
#bright_foreground = ""
#cursor            = { text = "CellBackground", cursor = "CellForeground" }

[colors.normal]
black   = "#%{colours.normal.black}"
red     = "#%{colours.normal.red}"
green   = "#%{colours.normal.green}"
yellow  = "#%{colours.normal.yellow}"
blue    = "#%{colours.normal.blue}"
magenta = "#%{colours.normal.magenta}"
cyan    = "#%{colours.normal.cyan}"
white   = "#%{colours.normal.white}"

[colors.bright]
black   = "#%{colours.bright.black}"
red     = "#%{colours.bright.red}"
green   = "#%{colours.bright.green}"
yellow  = "#%{colours.bright.yellow}"
blue    = "#%{colours.bright.blue}"
magenta = "#%{colours.bright.magenta}"
cyan    = "#%{colours.bright.cyan}"
white   = "#%{colours.bright.white}"

[font]
#normal = { family = "Fisa Code", style = "Italic" }
size   = 7

"% }
