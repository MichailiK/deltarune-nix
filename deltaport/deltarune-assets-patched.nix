{
  # Arguments
  src,
  version ? null,
  deltaport,
  # nixpkgs inputs
  pkgs,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  inherit version;
  src = src;
  pname = "deltarune-assets-patched";

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
    export SCRIPTDIR="${deltaport}"
    "${deltaport}"/port.sh

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
