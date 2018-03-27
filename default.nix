{ compiler ? "ghc822" }:
  let
   config = {
     packageOverrides = pkgs: with pkgs.haskell.lib; {
       haskell = pkgs.haskell // {
         packages = pkgs.haskell.packages // {
            ${compiler} = pkgs.haskell.packages.${compiler}.override {
              overrides = self: super: rec {
                nanovg = 
                  buildStrictly (self.callPackage ../nanovg-hs/nanovg.nix {});
              };
           };
         };
      };
   };
};
in
  let
    pkgs = import <nixpkgs> { inherit config; };
    nanovg = pkgs.haskell.packages.${compiler}.nanovg;
in { inherit nanovg; }
