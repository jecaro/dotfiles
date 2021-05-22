#!/usr/bin/env bash

set -o errexit

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 dst [nix-build-arg-1 nix-build-arg-2 nix-build-arg-3 ...]"
    exit 1
fi

nix-build ${@:2} | xargs nix-copy-closure --to $1
