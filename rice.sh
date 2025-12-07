#!/usr/bin/env bash

WS=3
DELAY=0.4
DELAY_SPOTIFY=2.5

# Go to workspace 3
hyprctl dispatch workspace "$WS"
sleep "$DELAY"

######################
# 1) Spotify (left)
######################
spotify &
sleep "$DELAY_SPOTIFY"

######################
# 2) Neofetch (right)
######################
# next split will be to the right of Spotify
hyprctl dispatch layoutmsg "orientationright"
alacritty -t neofetch-term -e bash -lc "neofetch; exec bash" &
sleep "$DELAY"

# make absolutely sure focus is on Neofetch, not Spotify
hyprctl dispatch focuswindow "title:neofetch-term"
sleep "$DELAY"

######################
# 3) Peaclock under Neofetch
######################
# split Neofetch vertically (top/bottom)
hyprctl dispatch layoutmsg "orientationbottom"
alacritty -t peaclock-term -e bash -lc "peaclock; exec bash" &
sleep "$DELAY"

# ensure we’re now on Peaclock (bottom area)
hyprctl dispatch focuswindow "title:peaclock-term"
sleep "$DELAY"

######################
# 4) Cava beside Peaclock
######################
# split that bottom area horizontally (left/right)
hyprctl dispatch layoutmsg "orientationright"
alacritty -t cava-term -e bash -lc "cava; exec bash" &
