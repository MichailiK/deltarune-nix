{
  pkgs,
  stdenvNoCC,
  ...
}: stdenvNoCC.mkDerivation {
  pname = "deltaport";
  version = "a1d05a";
  buildInputs = [ pkgs.rsync pkgs.xdelta ];
  src = builtins.fetchGit {
    url = "https://github.com/pungus7/deltaport.git";
    ref = "main";
    rev = "a1d05acbf6ab08c57281ef05ebeeeecc8438d484";
  };
  patches = [
    ./0001-adjust-port-for-nix-packaging.patch
  ];

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';
}
