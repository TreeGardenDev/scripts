#!/bin/sh

#Purpose: Utilize unix socket to send status updates to the status bar.

# Dark Colors
 dBlack="#1e1c1a"
  dGray="#7e7c7a"
 dWhite="#ceccca"
  dBlue="#20419a"
dPurple="#5d377b"
  dPink="#883067"
   dRed="#962a1c"
dYellow="#916518"
 dGreen="#406d00"
  dTeal="#2d746e"

# Bright Colors
 bBlack="#4e4c4a"
  bGray="#9e9c9a"
 bWhite="#eeecea"
  bBlue="#5273cd"
bPurple="#8f69ad"
  bPink="#ba6299"
   bRed="#c85c4e"
bYellow="#c3974a"
 bGreen="#729f32"
  bTeal="#5fa6a0"

  

colorize() {
  echo "<span background='$dBlack' foreground='$bWhite'><span foreground='$1'> $2 </span>$3 </span>"
}

glow=$(colorize $dYellow "󰃞" $(light -G | awk -F '.' '{print $1}'))

battery_icon() {
  case 1 in
    $(($1<=5)) ) echo "󱃍";;
    $(($1<=15))) echo "󰁺";;
    $(($1<=25))) echo "󰁻";;
    $(($1<=35))) echo "󰁼";;
    $(($1<=45))) echo "󰁽";;
    $(($1<=55))) echo "󰁾";;
    $(($1<=65))) echo "󰁿";;
    $(($1<=75))) echo "󰂀";;
    $(($1<=85))) echo "󰂁";;
    $(($1<=95))) echo "󰂂";;
    *          ) echo "󰁹";;
  esac
}

charge_color() {
  if [[ $(($1<=10)) == 1 ]]
  then
    echo $bRed
  else
    echo $bGreen
  fi
}

battery() {
  charge=$(cat /sys/class/power_supply/BATT/capacity)
  status=$(cat /sys/class/power_supply/BATT/status)
  
  if [ "$status" = "Charging" ]
  then
    icon=$(charging_icon $charge)
  else
    icon=$(battery_icon $charge)
  fi
  
  echo "$(colorize $(charge_color $charge) $icon $charge)"
}


volume_icon() {
  case 1 in
    $(($1<=34))) echo "󰕿";;
    $(($1<=68))) echo "󰖀";;
    *          ) echo "󰕾";;
  esac
}


volume() {
  level=$(
    pactl get-sink-volume @DEFAULT_SINK@ | head -n1 |
    awk '{print substr($5, 1, length($5)-1)}'
  )
  mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
  case $mute in
    yes) icon="󰸈";;
    no)  icon=$(volume_icon $level);;
  esac
  echo "$(colorize $bPink $icon $level)"
}



clock_icon() {
  case `date +%-I` in
     1) echo "󱐿";;
     2) echo "󱑀";;
     3) echo "󱑁";;
     4) echo "󱑂";;
     5) echo "󱑃";;
     6) echo "󱑄";;
     7) echo "󱑅";;
     8) echo "󱑆";;
     9) echo "󱑇";;
    10) echo "󱑈";;
    11) echo "󱑉";;
    12) echo "󱑊";;
  esac
}

time=$(colorize $bPurple `clock_icon` $(date +"%-I:%M%P"))

day_suffix() {
  case `date +%-d` in
    1|21|31) echo "st";;
    2|22)    echo "nd";;
    3|23)    echo "rd";;
    *)       echo "th";;
  esac
}

date=$(colorize $bBlue "󰃭" "$(date +"%a %b %-d`day_suffix`")")

free_mem=$(colorize $bBlue "Used:" "$(free -h | rg "Mem:" | awk '{print $3}')");

temp=$(colorize $bYellow "Temp:" "$(sensors | rg -A1 "Adapter: ACPI" | rg "temp1" | awk '{print $2}')") ;

cpu_ut=$(colorize $bTeal "CPU:" "$(iostat -c | awk '{print $1+$3}'  | sed -n '4 p')");

#Get title of the focused window
wind=$(colorize $dRed "Win:" "`swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .name'`");

printf "$wind $cpu_ut $temp $free_mem $glow `volume` `battery` $time $date \n" | nc -N -U /tmp/status_pipe
