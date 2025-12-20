#!/bin/bash

txt=$(playerctl --player=spotify metadata --format "{{ title }} — {{ artist }}" 2>/dev/null)

if [ -z "$txt" ]; then
    exit 0
fi

# Max characters shown
max=40

if [ ${#txt} -gt $max ]; then
    echo "${txt:0:max}..."
else
    echo "$txt"
fi
