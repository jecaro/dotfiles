#!/usr/bin/env bash

ssh -tt -G $1 | awk '/^hostname / { print $2 }'
