#!/usr/bin/env bash

# Portal arguments passed by xdg-desktop-portal-termfilechooser:
multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

# 1. Determine starting directory and suggested filename
if [ -d "$path" ]; then
    start_dir="$path"
    suggested=""
else
    start_dir=$(dirname "$path")
    suggested=$(basename "$path")
fi

# Fallback to HOME if directory is invalid
if [ ! -d "$start_dir" ]; then
    start_dir="$HOME"
fi

cd "$start_dir" || exit 1

# 2. Handle request types
if [ "$save" = "1" ]; then
    # Step 1: Pick directory (absolute paths starting at $HOME)
    target_dir=$(fd --type d --hidden --absolute-path --exclude .git . "$HOME" | rofi -dmenu -i -p "1. Pick Save Folder:")
    
    if [ -z "$target_dir" ]; then exit 1; fi
    
    # Step 2: Type filename
    filename=$(rofi -dmenu -i -p "2. Save As:" -filter "$suggested" -lines 0 < /dev/null)
    
    if [ -n "$filename" ]; then
        full_path=$(realpath -m "$target_dir/$filename")
        
        # Ensure parent directory exists and touch file so termfilechooser's stat() passes
        mkdir -p "$(dirname "$full_path")"
        touch "$full_path"
        
        echo "$full_path" > "$out"
        exit 0
    else
        exit 1
    fi

elif [ "$directory" = "1" ]; then
    # --- DIRECTORY DIALOG ---
    selected=$(fd --type d --hidden --absolute-path --exclude .git | rofi -dmenu -i -p "Select Directory:")
    
    if [ -n "$selected" ]; then
        realpath "$selected" > "$out"
        exit 0
    else
        exit 1
    fi

else
    # --- FILE DIALOG ---
    selected=$(fd --type f --hidden --absolute-path --exclude .git | rofi -dmenu -i -p "Open File:")
    
    if [ -n "$selected" ]; then
        realpath "$selected" > "$out"
        exit 0
    else
        exit 1
    fi
fi
