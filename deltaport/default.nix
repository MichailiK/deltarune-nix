{
  supportsSystem = system: system == "x86_64-linux";
  supportsVersion = versionInfo: versionInfo.version == "1.01C";
  mkDeltarunePkgs =
    {
      version,
      assets,
      chapters,
      forEachChapter,
      mkYoYoGamesRunner,
      libtas,
      pkgs,
      ...
    }:
    let
      deltarune = pkgs.callPackage ./deltarune.nix {
        inherit version mkYoYoGamesRunner;
        src = assets;
      };
    in
    {
      default = deltarune;
    }
    // forEachChapter (chapter: {
      "ch${chapter}" = pkgs.writeShellApplication {
        name = "deltarune-${version}-ch${chapter}+deltaport";
        text = "${deltarune}/bin/chapter${chapter}_linux/deltarune";
      };

      "ch${chapter}-libtas" = pkgs.writeShellApplication {
        name = "deltarune-${version}-ch${chapter}-libtas+deltaport";
        runtimeInputs = [ libtas ];
        # Forcing libTAS to use X11 as Wayland is not supported
        text = ''QT_QPA_PLATFORM=xcb libTAS "${deltarune}/bin/chapter${chapter}_linux/deltarune"'';
      };
    });
}
