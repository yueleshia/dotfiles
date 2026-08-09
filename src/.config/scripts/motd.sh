#!/bin/sh

# message of the day, run from .bashrc

# DOTREMINDERS is remint
[ -d "${DOTREMINDERS}" ] && {
  cd "${DOTREMINDERS}"
  printf %s\\n "$( date '+%Y/%m/%d' ) (Today)"
  # -m start with monday, -s simple, + weeks, -@ use colors
  remind -s+2 -@ -m .
}
