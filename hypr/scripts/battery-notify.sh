#!/bin/sh
# Low-battery notifications. Started from Hyprland autostart.
# Warns once per threshold while discharging; resets when plugged in.

WARN=20
CRIT=10
DANGER=5
INTERVAL=60

# only one copy at a time
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/battery-notify.lock"
flock -n 9 || exit 0

percent() {
    # combined level across both batteries
    now=0; full=0
    for b in /sys/class/power_supply/BAT*; do
        [ -r "$b/energy_full" ] || continue
        now=$((now + $(cat "$b/energy_now")))
        full=$((full + $(cat "$b/energy_full")))
    done
    [ "$full" -gt 0 ] && echo $((now * 100 / full)) || echo 100
}

time_left() {
    upower -i /org/freedesktop/UPower/devices/DisplayDevice 2>/dev/null \
        | awk -F': *' '/time to empty/ {print " · " $2 " left"}'
}

notify() { # urgency icon title
    notify-send -u "$1" -i "$2" -a "Battery" "$3" "$(time_left | sed 's/^ · //')"
}

last=100
while true; do
    pct=$(percent)
    if [ "$(cat /sys/class/power_supply/AC/online 2>/dev/null)" = 1 ]; then
        last=100
    elif [ "$pct" -le $DANGER ] && [ $last -gt $DANGER ]; then
        notify critical battery-caution "Battery critically low · ${pct}%  — plug in now"
        last=$DANGER
    elif [ "$pct" -le $CRIT ] && [ $last -gt $CRIT ]; then
        notify critical battery-caution "Battery low · ${pct}%"
        last=$CRIT
    elif [ "$pct" -le $WARN ] && [ $last -gt $WARN ]; then
        notify normal battery-low "Battery at ${pct}%"
        last=$WARN
    fi
    sleep $INTERVAL
done
