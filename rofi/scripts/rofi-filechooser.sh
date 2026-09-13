#!/usr/bin/env bash

# The portal always passes exactly 5 arguments:
multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

# 1. Figure out the starting directory and suggested filename
if [ -d "$path" ]; then
    start_dir="$path"
    suggested=""
else
    start_dir=$(dirname "$path")
    suggested=$(basename "$path")
fi

# Fallback to HOME if the application provided a weird path
if [ ! -d "$start_dir" ]; then
    start_dir="$HOME"
fi

# Change to the target directory so 'fd' and relative paths work perfectly
cd "$start_dir" || exit 1

# 2. Handle the specific request type
if [ "$save" = "1" ]; then
    # Step 1: Pick the directory from a list
    target_dir=$(fd --type d --hidden --exclude .git . "$HOME" | rofi -dmenu -i -p "1. Pick Save Folder:")
    
    # If you press Escape, abort the save
    if [ -z "$target_dir" ]; then exit 1; fi
    
    # Step 2: Type the file name
    filename=$(echo "" | rofi -dmenu -i -p "2. Save As:" -filter "$suggested" -lines 0)
    
    if [ -n "$filename" ]; then
        # Combine the chosen directory and the typed filename
        echo "$target_dir/$filename" > "$out"
    fi

elif [ "$directory" = "1" ]; then
    # --- DIRECTORY DIALOG ---
    # Find directories only
    selected=$(fd --type d --hidden --exclude .git | rofi -dmenu -i -p "Select Directory:")
    
    if [ -n "$selected" ]; then
        realpath "$selected" > "$out"
    fi

else
    # --- FILE DIALOG ---
    # Find files only
    selected=$(fd --type f --hidden --exclude .git | rofi -dmenu -i -p "Open File:")
    
    if [ -n "$selected" ]; then
        realpath "$selected" > "$out"
    fi
fi
