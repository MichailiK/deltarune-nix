{
  nixpkgs,
  yoyo-games-runner,
  forAllSystems,
}: let
  versionInfos = import ./version-infos.nix;
  latestVersionInfo = nixpkgs.lib.last versionInfos;

  # Returns true if the runtime supports the specified system/architecture, false if not.
  runtimeSupportsSystem = system: runtimeName: builtins.elem system (import ./${runtimeName}).supportedSystems;
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
    default ? false,
  }: let
    system = pkgs.stdenv.hostPlatform.system;

    # Not all runtimes may support this system, e.g. deltaport doesnt support aarch64, so this filters them out
    supportedRuntimeNames = pkgs.lib.filter (runtimeName: runtimeSupportsSystem system runtimeName) versionInfo.supportedRuntimes;
    # Find the first runtime that supports this system & appears first in the supported runtimes for this version of Deltarune
    preferredRuntimeName = pkgs.lib.findFirst (runtimeName: builtins.elem runtimeName versionInfo.supportedRuntimes) null supportedRuntimeNames;

    assets = pkgs.requireFile {
      name = "deltarune";
      sha256 = versionInfo.assetsHash;
      hashMode = "recursive";
      message = ''
        A copy of the Windows game files of DELTARUNE version ${versionInfo.version} must be added to the Nix store. For more information please see https://github.com/MichailiK/deltarune-nix#download-deltarune

        QUICK GUIDE:

        ${
          if default || (latestVersionInfo == versionInfo)
          then ''
            - Download DELTARUNE from Steam. Ensure you have version ${versionInfo.version} installed. Go to the game files (Steam Library -> right click DELTARUNE -> Manage -> Browse local files), copy the directory path and use this command to add the game files: nix store add-path --name deltarune GAME_FILES_PATH

            ${
              if default
              then ''
                - If there is a newer version of DELTARUNE, it is currently not supported by this Nix flake. Please open an issue at https://github.com/MichailiK/deltarune-nix/issues to request an update to the latest game version.
                - In the meantime, you can download DELTARUNE version ${versionInfo.version} using the Steam console.''
              else "- If you have a newer version installed, you have the possibility of downloading DELTARUNE version ${versionInfo.version} using the Steam console."
            }''
          else "- To download old versions of DELTARUNE, you must own DELTARUNE on Steam & use the Steam console."
        }

        - To download DELTARUNE ${versionInfo.version} through the Steam console:
          1. EITHER open steam://open/console -OR- relaunch Steam with the "-console" argument.
          2. In the console's text field, paste the following: download_depot 1671210 1671212 ${versionInfo.steamManifestId}
          3. Steam will print "Downloading depot 1671212 (123 files, 456 MB) ..." to the console to indicate it is downloading DELTARUNE ${versionInfo.version}.
          4. Wait for the download to finish. Steam will print the following to the console once its done: "Depot download complete : "/home/USER/.local/share/Steam/ubuntu12_32\steamapps\content\app_1671210\depot_1671212" (manifest ${versionInfo.steamManifestId})"
          5. To add the game files to the Nix store, use the following command: nix store add-path --name deltarune ~/.local/share/Steam/ubuntu12_32/steamapps/content/app_1671210/depot_1671212


        Further instructions & notes for installing DELTARUNE versions can be found at https://github.com/MichailiK/deltarune-nix#download-deltarune
      '';
    };

    runtimesPkgs = pkgs.lib.pipe supportedRuntimeNames [
      (builtins.map (runtimeName: {
        name = runtimeName;
        value = mkDeltarunePkgsWithRuntime {inherit runtimeName versionInfo assets pkgs;};
      }))
      builtins.listToAttrs
    ];
  in
    # flatten the runtimePkgs attribute set append `+{runtime}` suffix to all packages
    (pkgs.lib.pipe runtimesPkgs [
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
    ])
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
        versionInfo = latestVersionInfo;
        default = true;
      })
      # versioned package names, e.g. v1_00, v1_01A-ch1, v1_01A-ch2-libtas, ...
      // (pkgs.lib.pipe versionInfos [
        (builtins.map (versionInfo:
          pkgs.lib.pipe versionInfo [
            (versionInfo: mkDeltarunePkgsOfVersion {inherit pkgs versionInfo;})
            (
              pkgs.lib.mapAttrs' (name: value: let
                newName = pkgs.lib.removePrefix "default" name;
                withDash = (builtins.stringLength newName != 0) && !(pkgs.lib.hasPrefix "+" newName);
                version = builtins.replaceStrings ["."] ["_"] versionInfo.version;
              in {
                name = "v${version}${
                  if withDash
                  then "-"
                  else ""
                }${newName}";
                value = value;
              })
            )
          ]))
        pkgs.lib.mergeAttrsList
      ])
  )
