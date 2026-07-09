{
  supportsSystem = system: system == "x86_64-linux" || system == "aarch64-linux";
  supportsVersion = versionInfo: true; # every version is supported
  mkDeltarunePkgs = {
    versionInfo,
    version,
    assets,
    chapters,
    forEachChapter,
    mkYoYoGamesRunner,
    libtas,
    pkgs,
    ...
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
        gameAssets =
          if (versionInfo.chapters < 5) then
            assets
          else
            # patch chapter 5 videos to include a silent audio stream on them
            # to prevent a softlock
            pkgs.runCommand "deltarune-assets-patched"
              {
                nativeBuildInputs = [pkgs.ffmpeg];
              }
              ''
                mkdir "$out"
                cp -r "${assets}/." "$out/"
                chmod -R u+w "$out"

                shopt -s nullglob
                for f in "$out"/chapter5_windows/vid/*.mp4; do
                  if ffprobe -v error -select_streams a -show_entries stream=index \
                       -of csv=p=0 "$f" | grep -q .; then
                    continue  # already has audio, leave it
                  fi
                  tmp="$(mktemp -p "$(dirname "$f")" --suffix=.mp4)"
                  ffmpeg -nostdin -v error -y \
                    -i "$f" \
                    -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=48000 \
                    -map 0:v:0 -map 1:a:0 -shortest \
                    -c:v copy -c:a aac \
                    "$tmp"
                  mv -f "$tmp" "$f"
                done
              '';
        includeFFmpeg = true; # Chapters 3 and 5 contain video
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
