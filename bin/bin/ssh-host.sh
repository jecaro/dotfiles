#!/usr/bin/env bash

set -o nounset
set -o errexit

SCRIPT_NAME=$(basename $0)
if [ SCRIPT_NAME != "ssh-host.sh" ]; then
    HOST=$SCRIPT_NAME
else
    HOST=$1
fi

ssh -tt -G $HOST | awk '/^hostname / { print $2 }'
