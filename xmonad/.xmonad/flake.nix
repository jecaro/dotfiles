{
  # From nix flakes init -t templates#haskell-hello
  inputs.nixpkgs.url = "nixpkgs";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });
    in
    {
      overlay = (final: prev: {
        xmonad-config = final.haskellPackages.callCabal2nix "xmonad-config" ./. {};
      });
      packages = forAllSystems (system: {
         xmonad-config = nixpkgsFor.${system}.xmonad-config;
      });
      defaultPackage = forAllSystems (system: self.packages.${system}.xmonad-config);
      checks = self.packages;
      devShell = forAllSystems (system: let haskellPackages = nixpkgsFor.${system}.haskellPackages;
        in haskellPackages.shellFor {
          packages = p: [self.packages.${system}.xmonad-config];
          withHoogle = true;
          buildInputs = with haskellPackages; [
            haskell-language-server
            ghcid
            cabal-install
          ];
        # Change the prompt to show that you are in a devShell
        shellHook = "export PS1='\\[\\e[1;34m\\]dev > \\[\\e[0m\\]'";
        });
  };
}
