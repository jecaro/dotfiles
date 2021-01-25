#!/usr/bin/env bash

ssh -G $1 | awk '/^hostname / { print $2 }'
