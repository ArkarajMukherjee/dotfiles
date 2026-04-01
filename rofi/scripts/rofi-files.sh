#!/usr/bin/env bash

if [ "$ROFI_RETV" -eq 0 ]; then
    # -H includes hidden files, -t f limits it strictly to files so you don't accidentally try to open a folder
    fd -H -t f . ~ 

elif [ "$ROFI_RETV" -eq 1 ]; then
    if [ -n "$1" ]; then
        FILE="$1"
        
        # Extract the file extension and convert it to lowercase for safe matching
        EXT="${FILE##*.}"
        EXT="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"

        case "$EXT" in
            # Documents
            pdf|djvu|epub)
                nohup zathura "$FILE" >/dev/null 2>&1 &
                ;;
                
            # Office Files
            xlsx|xls|docx|doc|pptx|ppt|odt|ods|odp|csv)
                nohup libreoffice "$FILE" >/dev/null 2>&1 &
                ;;
                
            # Video
            mp4|mkv|webm|avi|mov|flv|wmv)
                nohup mpv "$FILE" >/dev/null 2>&1 &
                ;;
                
            # Audio
            mp3|flac|wav|ogg|m4a|aac)
                nohup mpv --force-window=no "$FILE" >/dev/null 2>&1 &
                ;;
                
            # Images
            png|jpg|jpeg|svg|webp|gif|bmp)
                # Using feh. (Install it with 'sudo pacman -S feh' if you don't have it)
                nohup feh "$FILE" >/dev/null 2>&1 &
                ;;
                
            # Anything else, including code (C, R, LaTeX, etc.) and files with no extension
            *)
                nohup kitty -e vim "$FILE" >/dev/null 2>&1 &
                ;;
        esac
    fi
fi
