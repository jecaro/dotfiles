#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "usage: $0 <monitor>"
fi

# the single quotes are neccessary to prevent command substitution
trap 'kill $(jobs -p) 2>/dev/null' SIGTERM EXIT

monitor="$1"
display=$(echo "$DISPLAY" | tr -d ':')
fifo="/tmp/polybar-${display}.${monitor}-stdin.fifo"
[ -p "$fifo" ] || mkfifo "$fifo"

MONITOR="$monitor" STDINFIFO="$fifo" polybar top &

cat > "$fifo"
