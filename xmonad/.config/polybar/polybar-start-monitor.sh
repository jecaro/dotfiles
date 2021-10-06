#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "usage: $0 <monitor>"
fi

# the single quotes are necessary to prevent command substitution
trap 'kill $(jobs -p) 2>/dev/null' SIGTERM EXIT

monitor="$1"
display=$(echo "$DISPLAY" | tr -d ':')
fifo="/tmp/polybar-${display}.${monitor}-stdin.fifo"
[ -p "$fifo" ] || mkfifo "$fifo"

backlight_card=$(ls -1 /sys/class/backlight/)

MONITOR="$monitor" STDINFIFO="$fifo" BACKLIGHT_CARD="$backlight_card" polybar top &

cat > "$fifo"
