#!/bin/sh

cleanup() {
  rm -f /tmp/status_pipe
}

trap cleanup EXIT
trap "exit" INT


generate_status="$HOME/.local/bin/statusbar.sh"


#similar to  the brightness, how would this search for time change

($generate_status) &
(
  inotifywait -m -e close_write /sys/class/backlight/amdgpu_bl1/brightness |
  while read -r; do $generate_status; done
) &
(
  pactl subscribe |
  rg --line-buffered 'change.*sink' |
  while IFS= read -r line; do $generate_status; done
) &
##Loop to do similar to systemd run every 10 seconds
while true; do
  $generate_status
  sleep 5
done &
nc -k -l -U /tmp/status_pipe | while IFS='\n' read -r current_status; do
  printf "$current_status\n"
done

