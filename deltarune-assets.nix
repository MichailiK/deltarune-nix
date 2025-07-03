{
  # Arguments
  src,
  version ? null,
  deltaport,
  # nixpkgs inputs
  pkgs,
  stdenv,
  lib,
  ...
}:

let
  _deltaport = pkgs.callPackage deltaport { };
  _src = builtins.toString src;
in
assert lib.assertMsg (lib.pathIsDirectory _src) "DELTARUNE game files must be a directory";
stdenv.mkDerivation {

  inherit version;
  src = _src;
  pname = "deltarune-assets";  

  nativeBuildInputs = [
    pkgs.rsync
    pkgs.xdelta
  ];


  unpackPhase = ''
   runHook preUnpack

    mkdir -p assets
    cp -r "$src"/* ./assets/
    chmod -R 755 ./assets/

    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    export DELTARUNEDIR="$(pwd)/assets"
    export SCRIPTDIR="${_deltaport}"
    "${_deltaport}"/port.sh

    chmod -R 755 ./assets/DELTARUNE.sh ./assets/deltarune ./assets/lib ./assets/chapter*_linux/deltarune
    rm -r ./assets/DELTARUNE.sh ./assets/deltarune ./assets/lib ./assets/chapter*_linux/deltarune

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/
    cp -r ./assets/* "$out"/

    runHook postInstall
  '';

}
