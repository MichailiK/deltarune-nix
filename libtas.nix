{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  autoreconfHook,
  pkg-config,
  SDL2,
  xorg,
  alsa-lib,
  ffmpeg,
  lua5_4,
  qt5,
  file,
  binutils,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtas";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "clementgallet";
    repo = "libTAS";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/hyKJ8HGLN7hT+9If/lcp0C7GnhJMRpc7EKDgA1kQcI=";
  };

  patches = [
    (fetchurl { 
      url = "https://github.com/clementgallet/libTAS/commit/779ff0fb0f3accfc62949680d85ecf96b28d18ef.patch";
      hash = "sha256-xAaTWIXt8FkMu6GE5mBWtLypROFZ1aEqmBTtG+6rTWk=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    qt5.wrapQtAppsHook
    pkg-config
    ffmpeg.dev
  ];
  buildInputs = [
    SDL2
    alsa-lib
    ffmpeg.bin
    ffmpeg.lib
    lua5_4
    qt5.qtbase
    xorg.libXi
  ];

  configureFlags = [
    "--enable-release-build"
  ];

  postInstall = ''
    mkdir -p $out/lib
    mv $out/bin/libtas*.so $out/lib/
  '';

  enableParallelBuilding = true;

  postFixup = ''
    wrapProgram $out/bin/libTAS \
      --suffix PATH : ${
        lib.makeBinPath [
          file
          binutils
          ffmpeg.bin
        ]
      } \
      --suffix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          ffmpeg.lib
          xorg.libXi
        ]
      } \
      --set-default LIBTAS_SO_PATH $out/lib/libtas.so
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "libTAS";
      desktopName = "libTAS";
      exec = "libTAS %U";
      icon = "libTAS";
      startupWMClass = "libTAS";
      keywords = [ "libTAS" ];
    })
  ];

  meta = {
    homepage = "https://clementgallet.github.io/libTAS/";
    changelog = "https://github.com/clementgallet/libTAS/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    description = "GNU/Linux software to give TAS tools to games";
    license = lib.licenses.gpl3Only;
    mainProgram = "libTAS";
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
})