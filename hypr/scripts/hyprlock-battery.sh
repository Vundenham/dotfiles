#!/bin/sh
# Prints a battery icon + percentage for hyprlock (handles dual-battery laptops)
now=0; full=0
for b in /sys/class/power_supply/BAT*; do
    [ -r "$b/energy_full" ] || continue
    now=$((now + $(cat "$b/energy_now")))
    full=$((full + $(cat "$b/energy_full")))
done
[ "$full" -gt 0 ] || exit 0
pct=$((now * 100 / full))
if [ "$(cat /sys/class/power_supply/AC/online 2>/dev/null)" = 1 ]; then icon="󰂄"
elif [ $pct -ge 90 ]; then icon="󰁹"
elif [ $pct -ge 70 ]; then icon="󰂀"
elif [ $pct -ge 50 ]; then icon="󰁾"
elif [ $pct -ge 30 ]; then icon="󰁼"
elif [ $pct -ge 15 ]; then icon="󰁺"
else icon="<span foreground='#BF616A'>󰂃</span>"; fi
echo "$icon  $pct%"
