#!/bin/sh

#Move the currently focused container to the next empty workspace
#next_ws=$(swaymsg -t get_workspaces | jq '[.[].num] | max + 1')
next_ws=$(swaymsg -t get_workspaces | jq '[.[].num]')
#Returns array ex: [1,2,8] iterat
for=$(seq 1 20) # Adjust the range as needed
for i in $for; do
    if ! echo "$next_ws" | grep -q "\b$i\b"; then
        next_ws=$i
        break
    fi
done
current_ws=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .workspace')

swaymsg move container to workspace $next_ws
swaymsg workspace $next_ws
