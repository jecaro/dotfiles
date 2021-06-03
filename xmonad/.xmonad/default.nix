{ pkgs ? import <nixos-unstable> {} }:
pkgs.haskellPackages.callCabal2nix "xmonad-config" ./. {}
