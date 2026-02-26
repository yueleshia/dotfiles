#!/bin/sh
fcitx5-remote -c
choice="$(
  {
    printf %s\\n "#en1 keyboard-us"
    printf %s\\n "#en2 keyboard-us-alt-intl-unicode"
    printf %s\\n "#en3 keyboard-cn-altgr-pinyin"
    printf %s\\n "#jp1 mozc"
    printf %s\\n "#jp2 anthy"
    printf %s\\n "#jp3 kkc"
    printf %s\\n "#zh1 pinyin"
    printf %s\\n "#zh2 array30"
    printf %s\\n "#zh3 rime"
    printf %s\\n "#kr1 hangul"
  } | fuzzel --search '#' --dmenu --no-mouse --no-sort
)" || {
  fcitx5-remote -o
  exit 1
}

notify-send "${choice}"
fcitx5-remote -s "${choice%% *}"
