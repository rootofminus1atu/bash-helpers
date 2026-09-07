#!/bin/bash
set -euo pipefail

LED="/sys/class/leds/hda::micmute/brightness"
last_state=""

check_and_set_led() {
    local muted
    muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

    if [ "$muted" != "$last_state" ]; then
        if [ "$muted" = "yes" ]; then
            echo 0 > "$LED"
        else
            echo 1 > "$LED"
        fi
        echo "Mic muted: $muted"
        last_state="$muted"
    fi
}

check_and_set_led

pactl subscribe | grep --line-buffered "on source" | while read -r _; do
    check_and_set_led
done