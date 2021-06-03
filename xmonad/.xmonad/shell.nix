{ pkgs ? import <nixos-unstable> {} }:
let
  project = import ./. { inherit pkgs; };
in
  with pkgs;
  mkShell {
    inputsFrom = [ project.env ];
    buildInputs = [
      ghcid
      haskellPackages.cabal-install
      haskellPackages.haskell-language-server
      haskellPackages.hlint
      haskellPackages.implicit-hie
    ];
  }
