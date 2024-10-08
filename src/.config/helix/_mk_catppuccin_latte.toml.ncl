#run: nickel export % --field text --format raw

{ executable = false, text = m%"
# Catppuccin Latte
# -------------------
"type" = "yellow"
"type.enum.variant" = "peach"

"constructor" = "sapphire"

"constant" = "peach"
"constant.character" = "teal"
"constant.character.escape" = "pink"

"string" = "green"
"string.regexp" = "peach"
"string.special" = "pink"

"comment" = { fg = "overlay1" }

"variable" = "text"
"variable.parameter" = { fg = "maroon" }
"variable.builtin" = "red"
"variable.other.member" = "teal"

"label" = "sapphire" # used for lifetimes

"punctuation" = "overlay2"

"keyword" = "mauve"
"keyword.control.conditional" = { fg = "mauve" }

"operator" = "sky"

"function" = "blue"
"function.builtin" = "peach"
"function.macro" = "teal"

"tag" = "mauve"

"namespace" = { fg = "blue" }

"special" = "blue" # fuzzy highlight

"markup.heading.marker" = { fg = "peach", modifiers = ["bold"] }
"markup.heading.1" = "lavender"
"markup.heading.2" = "mauve"
"markup.heading.3" = "green"
"markup.heading.4" = "yellow"
"markup.heading.5" = "pink"
"markup.heading.6" = "teal"
"markup.list" = "mauve"
"markup.bold" = { modifiers = ["bold"] }
"markup.italic" = { modifiers = ["italic"] }
"markup.link.url" = { fg = "peach", modifiers = ["underlined"] }
"markup.link.text" = "blue"
"markup.raw" = "flamingo"

"diff.plus" = "green"
"diff.minus" = "red"
"diff.delta" = "yellow"

# User Interface
# --------------
"ui.background" = { fg = "text", bg = "base" }

"ui.linenr" = { fg = "surface1" }
"ui.linenr.selected" = { fg = "lavender" }

"ui.statusline" = { fg = "overlay1", bg = "surface0" }
"ui.statusline.inactive" = { fg = "overlay1", bg = "mantle" }
"ui.statusline.normal" = { fg = "surface0", bg = "lavender", modifiers = ["bold"] }
"ui.statusline.insert" = { fg = "surface0", bg = "green", modifiers = ["bold"]  }
"ui.statusline.select" = { fg = "surface0", bg = "flamingo", modifiers = ["bold"]  }

"ui.popup" = { fg = "text", bg = "surface0" }
"ui.window" = { fg = "crust" }
"ui.help" = { fg = "overlay2", bg = "surface0" }

"ui.text" = "text" 
"ui.text.focus" = { fg = "text", bg = "surface0", modifiers = ["bold"] }

"ui.virtual" = "overlay0"
"ui.virtual.ruler" = { bg = "surface0" }
"ui.virtual.indent-guide" = "surface0"

"ui.selection" = { bg = "surface1" }

"ui.cursor" = { fg = "base", bg = "secondary_cursor" }
"ui.cursor.primary" = { fg = "base", bg = "rosewater" }
"ui.cursor.match" = { fg = "peach", modifiers = ["bold"] }

"ui.cursorline.primary" = { bg = "cursorline" }

"ui.highlight" = { bg = "surface1" }

"ui.menu" = { fg = "overlay2", bg = "surface0" }
"ui.menu.selected" = { fg = "text", bg = "surface1", modifiers = ["bold"] }

diagnostic = { modifiers = ["underlined"] }

error = "red"
warning = "yellow"
info = "sky"
hint = "teal"

[palette]
# catppuccin palette colors
rosewater = "#dc8a78"
flamingo = "#dd7878"
pink = "#ea76cb"
mauve = "#8839ef"
red = "#d20f39"
maroon = "#e64553"
peach = "#fe640b"
yellow = "#df8e1d"
green = "#40a02b"
teal = "#179299"
sky = "#04a5e5"
sapphire = "#209fb5"
blue = "#1e66f5"
lavender = "#7287fd"

text = "#4c4f69"
subtext1 = "#5c5f77"
subtext0 = "#6c6f85"
overlay2 = "#7c7f93"
overlay1 = "#8c8fa1"
overlay0 = "#9ca0b0"
surface2 = "#acb0be"
surface1 = "#bcc0cc"
surface0 = "#ccd0da"

base = "#eff1f5"
mantle = "#e6e9ef"
crust = "#dce0e8"

# derived colors by blending existing palette colors
cursorline = "#e9ebf1"
secondary_cursor = "#e2a99e"

"% }
