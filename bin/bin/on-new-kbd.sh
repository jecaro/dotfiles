#!/usr/bin/env bash
# inputplug script found here:
# https://unix.stackexchange.com/questions/523635/prevent-keyboard-layout-reset-when-usb-keyboard-is-plugged-in

echo >&2 "$@"
event=$1 id=$2 type=$3

case "$event $type" in
'XIDeviceEnabled XISlaveKeyboard')
    ~/bin/setup-keyboard.sh
esac

