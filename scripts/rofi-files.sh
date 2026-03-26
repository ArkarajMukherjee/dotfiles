#!/usr/bin/env bash

if [ "$ROFI_RETV" -eq 0 ]; then
    # fd is radically faster and ignores .git/node_modules junk by default
    # -H includes hidden files, -t f limits it to files (removes directories from the list to reduce clutter, optional)
    fd -H . ~ 

elif [ "$ROFI_RETV" -eq 1 ]; then
    if [ -n "$1" ]; then
        kitty -e vim "$1" > /dev/null 2>&1 &
    fi
fi
