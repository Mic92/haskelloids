{ mkDerivation, affection, base, containers, glew, linear
, nanovg, OpenGL, random, sdl2, stdenv, stm
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
  executablePkgconfigDepends = [ glew sdl2 ];
  description = "A little game using Affection";
  license = stdenv.lib.licenses.gpl3;
}
