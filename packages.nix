{
  nixpkgs,
  yoyo-games-runner,
  forAllSystems,
}: let
  versionMetadata = import ./version-metadata.nix {inherit (nixpkgs) lib;};
  # List of runtimes that this package contains.
  # The runtimes placed at the front of the list get preference for the default package
  runtimes = ["deltarunner" "deltaport"];

  # Returns true if the runtime supports the specified system/architecture & Deltarune version, false if not.
  runtimeSupportsConfiguration = {
    runtimeName,
    versionInfo,
    pkgs,
  }: let
    runtime = import ./${runtimeName};
  in
    # supports system/architecture
    runtime.supportsSystem pkgs.stdenv.hostPlatform.system
    # supports game version
    && runtime.supportsVersion versionInfo;
  forEachChapter = chapters: callback:
    nixpkgs.lib.pipe chapters [
      # Create a list ranging from 1 to number of chapters, e.g. [1 2 3 4]
      (nixpkgs.lib.range 1)
      # Stringify all numbers to conveniently interpolate in strings
      (builtins.map builtins.toString)
      # Call callback with the chapter numbers
      (builtins.map callback)
      # Callbacks are expected to return attributes that get merged in the end
      # e.g. { ch1 = ...; ch1-libtas = ...; ch2 = ...; ... }
      nixpkgs.lib.mergeAttrsList
    ];

  mkDeltarunePkgsWithRuntime = {
    runtimeName,
    versionInfo,
    assets,
    pkgs,
  }:
    (import ./${runtimeName}).mkDeltarunePkgs {
      inherit versionInfo;
      version = versionInfo.version;
      assets = assets;
      chapters = versionInfo.chapters;
      forEachChapter = forEachChapter versionInfo.chapters;
      mkYoYoGamesRunner = yoyo-games-runner.mkYoYoGamesRunner;
      libtas = pkgs.callPackage ./libtas.nix {};
      pkgs = pkgs;
    };

  mkDeltarunePkgsOfVersion = {
    pkgs,
    versionInfo,
    isDefault ? false,
  }: let
    # Not all runtimes may support this system or version, e.g. deltaport only supports 1.01C and doesnt support aarch64, so this filters them out
    supportedRuntimeNames = pkgs.lib.filter (runtimeName: runtimeSupportsConfiguration {inherit runtimeName versionInfo pkgs;}) runtimes;
    # Find the first runtime that supports this system & appears first in the runtimes list
    preferredRuntimeName = pkgs.lib.findFirst (runtimeName: builtins.elem runtimeName supportedRuntimeNames) null runtimes;

    assets = versionMetadata.getAssetsPackage {inherit versionInfo isDefault pkgs;};

    runtimesPkgs = pkgs.lib.pipe supportedRuntimeNames [
      (builtins.map (runtimeName: {
        name = runtimeName;
        value = mkDeltarunePkgsWithRuntime {inherit runtimeName versionInfo assets pkgs;};
      }))
      builtins.listToAttrs
    ];
  in
    # flatten the runtimePkgs attribute set append `+{runtime}` suffix to all packages
    # do not generate if none or only 1 runtime supports this version
    (pkgs.lib.optionalAttrs (builtins.length (builtins.attrNames runtimesPkgs) > 1) (pkgs.lib.pipe runtimesPkgs [
      (builtins.mapAttrs (
        runtimeName: runtimePkgs:
          pkgs.lib.mapAttrs' (name: value: {
            name = "${name}+${runtimeName}";
            value = value;
          })
          runtimePkgs
      ))
      builtins.attrValues
      pkgs.lib.mergeAttrsList
    ]))
    # preferred runtime without the `+{runtime}` suffix
    // (
      if preferredRuntimeName == null
      then {}
      else runtimesPkgs.${preferredRuntimeName}
    );
in
  forAllSystems (
    pkgs:
    # latest version gets package names without versions, e.g. default, ch1, ch2-libtas, ...
      (mkDeltarunePkgsOfVersion {
        inherit pkgs;
        versionInfo = versionMetadata.latestPublicVersionInfo;
        isDefault = true;
      })
      # versioned package names, e.g. v1_00, v1_01A-ch1, v1_01A-ch2-libtas, ...
      // (pkgs.lib.pipe versionMetadata.versions [
        (builtins.map (versionInfo:
          pkgs.lib.pipe versionInfo [
            (versionInfo: mkDeltarunePkgsOfVersion {inherit pkgs versionInfo;})
            (
              pkgs.lib.mapAttrs' (name: value: let
                newName = pkgs.lib.removePrefix "default" name;
                optionalDash =
                  if (builtins.stringLength newName != 0) && !(pkgs.lib.hasPrefix "+" newName)
                  then "-"
                  else "";
                version = builtins.replaceStrings ["."] ["_"] versionInfo.version;
              in {
                name = "v${version}${optionalDash}${newName}";
                value = value;
              })
            )
          ]))
        pkgs.lib.mergeAttrsList
      ])
  )
