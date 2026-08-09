# I want the theme source have the pound, e.g. "#123456", and then strip them,
# because this way the vim plugin can highlight them
let alabaster = {
  background = "#f7f7f7",
  foreground = "#434343",

  normal = {
    black    = "#000000",
    red      = "#AA3731",
    green    = "#448C27",
    yellow   = "#CB9000",
    blue     = "#325CC0",
    magenta  = "#7A3E9D",
    cyan     = "#0083B2",
    white    = "#DDDDDD",
  },
  bright = {
    black    = "#777777",
    red      = "#F05050",
    green    = "#60CB00",
    yellow   = "#FFBC5D",
    blue     = "#007ACC",
    magenta  = "#E64CE6",
    cyan     = "#00AACB",
    white    = "#FFFFFF",
  },
} in

let one_light_custom = {
  background   = "#fcfcfc",
  foreground   = "#111111",

  normal = {
    black      = "#111111",
    red        = "#c82829",
    green      = "#50a14f",
    yellow     = "#c18401",
    blue       = "#4271ae",
    magenta    = "#8959a8",
    cyan       = "#3e999f",
    white      = "#fcfcfc"
  },

  bright = {
    black      = "#111111",
    red        = "#e45649",
    green      = "#718c00",
    yellow     = "#eab700",
    blue       = "#4271ae",
    magenta    = "#8959a8",
    cyan       = "#3e999f",
    white      = "#9e9e9e",
  },
} in


let strip_pound = fun s => std.string.substring 1 (std.string.length s) s in
alabaster |> (fun theme => {
  background   = strip_pound theme.background,
  foreground   = strip_pound theme.foreground,

  normal = theme.normal |> std.record.map_values strip_pound,
  bright = theme.bright |> std.record.map_values strip_pound,
})
