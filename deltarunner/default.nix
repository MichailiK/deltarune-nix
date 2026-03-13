{
  supportsSystem = system: system == "x86_64-linux" || system == "aarch64-linux";
  supportsVersion = versionInfo: true; # every version is supported
  mkDeltarunePkgs = {
    version,
    assets,
    chapters,
    forEachChapter,
    mkYoYoGamesRunner,
    libtas,
    pkgs,
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    deltarunner =
      if system == "x86_64-linux"
      then
        pkgs.fetchzip {
          url = "https://github.com/InvoxiPlayGames/DELTARUNNER/releases/download/v2/deltaRunner-v2-x86_64-2022.0.3.110.zip";
          hash = "sha256-R7CKKZ3xrbleARC6JUTP6DSIkSmfXfB29eqnFmocP1w=";
        }
      else if system == "aarch64-linux"
      then
        pkgs.fetchzip {
          url = "https://github.com/InvoxiPlayGames/DELTARUNNER/releases/download/v2/deltaRunner-v2-arm64-2022.0.3.110.zip";
          hash = pkgs.lib.fakeHash; # TODO
        }
      else builtins.abort "deltarunner got unexpectly called with unsupported system ${system}";

    wrappedRunner =
      (mkYoYoGamesRunner {
        system = "x86_64-linux";
        name = "deltarune";
        src = "${deltarunner}/deltaRunner";
        version = version + "+deltarunner";
        gameAssets = assets;
        includeFFmpeg = true; # Chapter 3 contains video
      }).overrideAttrs (final: prev: {
        runtimeDependencies =
          (prev.runtimeDependencies or [])
          ++ [
            pkgs.libpulseaudio
            pkgs.libxfixes
          ];

        autoPatchelfIgnoreMissingDeps = ["libopenal.so.1" "libpulse.so.0" "libXfixes.so.3"];
      });
  in
    {
      default = wrappedRunner;
    }
    // forEachChapter (chapter: {
      "ch${chapter}" = pkgs.writeShellApplication {
        name = "deltarune-${version}-ch${chapter}+deltarunner";
        text = "${pkgs.lib.getExe wrappedRunner} -gamedir /chapter${chapter}_windows -game data.win launcher switch_-1 returning_0";
      };

      "ch${chapter}-libtas" = pkgs.writeShellApplication {
        name = "deltarune-${version}-ch${chapter}-libtas+deltarunner";
        runtimeInputs = [libtas];
        # Forcing libTAS to use X11 as Wayland is not supported
        text = ''QT_QPA_PLATFORM=xcb libTAS ${pkgs.lib.getExe wrappedRunner} -gamedir /chapter${chapter}_windows -game data.win launcher switch_-1 returning_0'';
      };
    });
}
