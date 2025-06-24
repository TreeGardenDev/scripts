#!/bin/sh

# Find the next unused workspace number and switch to it
# #Go to the next unused window (ex: window 1 2 8 taken, go to 3)
#
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

swaymsg workspace number $next_ws
