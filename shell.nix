{ nixpkgs ? import <nixpkgs> {}
, compiler ? "default"
, doBenchmark ? false
, nanovg
}:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, affection, base, containers, glew
      , linear, nanovg, OpenGL, random, sdl2, stdenv, stm
      }:
      mkDerivation {
        pname = "haskelloids";
        version = "0.0.0.1";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [
          affection base containers linear nanovg OpenGL random sdl2 stm
        ];
        executableSystemDepends = [ glew ];
        executablePkgconfigDepends = [ glew ];
        description = "A little game using Affection";
        license = stdenv.lib.licenses.gpl3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
