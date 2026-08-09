#run: nickel export % --field text --format raw

let colours = import "meta/colours.ncl" in

{ executable = false, text = m%"
*foreground:  #%{colours.foreground}
*background:  #%{colours.background}
*cursorColor: #%{colours.foreground}

*color0:      #%{colours.normal.black}
*color1:      #%{colours.normal.red}
*color2:      #%{colours.normal.green}
*color3:      #%{colours.normal.yellow}
*color4:      #%{colours.normal.blue}
*color5:      #%{colours.normal.magenta}
*color6:      #%{colours.normal.cyan}
*color7:      #%{colours.normal.white}

*color8:      #%{colours.bright.black}
*color9:      #%{colours.bright.red}
*color10:     #%{colours.bright.green}
*color11:     #%{colours.bright.yellow}
*color12:     #%{colours.bright.blue}
*color13:     #%{colours.bright.magenta}
*color14:     #%{colours.bright.cyan}
*color15:     #%{colours.bright.white}

! This sets $TERM with the Xresources patch
! If you run into deletion errors, not having this is probably the problem
st.termname:   st-256color


! Can look through history for more exhausitive list of possible options
!st.alpha:      230
st.font:       mono:size=9:antialias=true:autohint=true;
!TODO figure out how to implement st.font2
st.borderpx:   4

"% }
