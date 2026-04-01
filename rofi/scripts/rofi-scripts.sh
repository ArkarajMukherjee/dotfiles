#!/usr/bin/env bash

if [ "$ROFI_RETV" -eq 0 ]; then
    # List contents of /bin
    ls -1 /bin

elif [ "$ROFI_RETV" -eq 1 ]; then
    if [ -n "$1" ]; then
        # Plainly output the script name. 
        echo "$1"
        
        # NOTE: If you launch Rofi from a Window Manager shortcut (like Super+A), 
        # standard output disappears into the void. If you want to actually use 
        # the output, uncomment the line below to copy it to your clipboard instead:
        # echo -n "$1" | xclip -selection clipboard
    fi
fi
