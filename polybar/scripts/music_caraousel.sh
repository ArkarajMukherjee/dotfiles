#!/bin/bash

zscroll -l 32 \
        --delay 0.20 \
        --scroll-padding "  " \
        --match-command "mpc status" \
        --match-text "playing" "--before-text '󰐊 ' --scroll 1" \
        --match-text "paused" "--before-text '󰏤 ' --scroll 0" \
        --update-check true "mpc current" &

wait
