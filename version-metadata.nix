{lib}: let
  metadata = builtins.fromJSON (builtins.readFile ./version-metadata.json);
in
  metadata
  // (lib.fix (self: {
    # Checks whether the provided version is in the default "public" branch or is only in a beta branch
    isPublicVersion = version: builtins.elem "public" version.steam_branches;

    # Latest version of the game on the default Steam branch
    latestPublicVersionInfo = lib.pipe metadata.versions [
      lib.reverseList
      (lib.findFirst self.isPublicVersion null)
    ];

    getAssetsPackage = {
      versionInfo,
      isDefault ? false,
      pkgs,
    }: let
      inherit (versionInfo) version;

      isPublic = self.isPublicVersion versionInfo;
      isLatestPublic = versionInfo == self.latestPublicVersionInfo;

      intro = ''
        A copy of the unmodified Windows game files for DELTARUNE version ${version} must be added to the Nix store.
        For more detailed instructions, please see https://github.com/MichailiK/deltarune-nix#download-deltarune
      '';

      steamDownloadHint = ''
        - Download DELTARUNE from Steam. Ensure you have version ${version} installed. Go to the game files (Steam Library -> right click DELTARUNE -> Manage -> Browse local files), copy the directory path and use this command to add the game files: nix store add-path --name deltarune GAME_FILES_PATH
      '';

      betaBranch = builtins.head versionInfo.steam_branches;

      versionNotes =
        if isDefault
        then ''
          - If there is a newer version of DELTARUNE, it is currently not supported by this Nix flake. Please open an issue at https://github.com/MichailiK/deltarune-nix/issues to request an update to the latest game version.
          - In the meantime, you can download DELTARUNE version ${version} using the Steam console.
        ''
        else if !isPublic
        then ''
          - This version is in a beta/experimental branch of DELTARUNE. To download it, go to your Steam library and right click DELTARUNE -> Properties... -> Game Versions & Betas -> Select "${betaBranch}"
          - Changing branches is treated as a game update, adding DELTARUNE to Steam's download queue. Wait for the download/update to complete.
          - Go to the game files (Steam Library -> right click DELTARUNE -> Manage -> Browse local files), copy the directory path and use this command to add the game files: nix store add-path --name deltarune GAME_FILES_PATH
        ''
        else if isLatestPublic
        then ''
          - If you have a newer version installed, you have the possibility of downloading DELTARUNE version ${version} using the Steam console.
        ''
        # Only old versions of DELTARUNE on the default "public" branch could/should cover this case
        else ''
          - To download old versions of DELTARUNE, you must own DELTARUNE on Steam & use the Steam console.
        '';

      appId = toString metadata.steam_app_id;
      depotId = toString metadata.steam_windows_depot_id;
      manifestId = versionInfo.steam_windows_manifest_id;

      steamConsoleInstructions = ''
        HOW TO DOWNLOAD DELTARUNE ${version} THROUGH STEAM CONSOLE:
          1. EITHER open steam://open/console -OR- relaunch Steam with the "-console" argument.
          2. In the console's text field, paste the following: download_depot ${appId} ${depotId} ${manifestId}
          3. Steam will print "Downloading depot ${depotId} (123 files, 456 MB) ..." to the console to indicate it is downloading DELTARUNE ${version}.
          4. Wait for the download to finish. Steam will print the following to the console once its done: "Depot download complete : "/home/USER/.local/share/Steam/ubuntu12_32\steamapps\content\app_${appId}\depot_${depotId}" (manifest ${manifestId})"
          5. To add the game files to the Nix store, use the following command: nix store add-path --name deltarune ~/.local/share/Steam/ubuntu12_32/steamapps/content/app_${appId}/depot_${depotId}
      '';

      buildId = toString versionInfo.steam_buildid;
      depotPath = "./depots/${depotId}/${buildId}";

      depotDownloaderInstructions = ''
        DOWNLOAD USING DEPOTDOWNLOADER:
        1. Use "depotdownloader -app ${appId} -depot ${depotId} -manifest ${manifestId}${lib.optionalString (!isPublic) " -beta ${betaBranch}"}" with your Steam credentials ("-username foobar", optionally "-qr" for convenient login with the Steam mobile app).
        2. Remove the temporary .DepotDownloader folder ("rm -r ${depotPath}/.DepotDownloader")
        3. Add executable bit to game assets ("chmod -R +x ${depotPath}")
        4. Add the game files to the Nix store using "nix store add-path --name deltarune ${depotPath}"
      '';

      outro = ''
        Retry this command once the above steps are done. If this error reoccurs, please check https://github.com/MichailiK/deltarune-nix#download-deltarune & ensure you're following the steps carefully.
      '';

      message = lib.concatStringsSep "\n" (
        [intro]
        ++ lib.optional (isDefault || isLatestPublic) steamDownloadHint
        ++ [versionNotes]
        ++ lib.optional isPublic steamConsoleInstructions
        ++ [
          depotDownloaderInstructions
          outro
        ]
      );
    in
      pkgs.requireFile {
        name = "deltarune";
        sha256 = versionInfo.nix_windows_nar_hash;
        hashMode = "recursive";
        inherit message;
      };
  }))
