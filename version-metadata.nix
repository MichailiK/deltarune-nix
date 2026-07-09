{lib}: let
  metadata = builtins.fromJSON (builtins.readFile ./version-metadata.json);
in
  metadata
  // (lib.fix (self: {
    # Checks whether the provided version in the default "public" branch or is only in a beta branch
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
    }:
      pkgs.requireFile {
        name = "deltarune";
        sha256 = versionInfo.nix_windows_nar_hash;
        hashMode = "recursive";
        message =
          ''
            A copy of the unmodified Windows game files for DELTARUNE version ${versionInfo.version} must be added to the Nix store.
            For more detailed instructions, please see https://github.com/MichailiK/deltarune-nix#download-deltarune

          ''
          + lib.optionalString (isDefault || (versionInfo == self.latestPublicVersionInfo)) "\n- Download DELTARUNE from Steam. Ensure you have version ${versionInfo.version} installed. Go to the game files (Steam Library -> right click DELTARUNE -> Manage -> Browse local files), copy the directory path and use this command to add the game files: nix store add-path --name deltarune GAME_FILES_PATH"
          + (
            if isDefault
            then ''

              - If there is a newer version of DELTARUNE, it is currently not supported by this Nix flake. Please open an issue at https://github.com/MichailiK/deltarune-nix/issues to request an update to the latest game version.
              - In the meantime, you can download DELTARUNE version ${versionInfo.version} using the Steam console.
            ''
            else if (!(self.isPublicVersion versionInfo))
            then ''
              - This version is in a beta/experimental branch of DELTARUNE. To download it, go to your Steam library and right click DELTARUNE -> Properties... -> Game Versions & Betas -> Select \"${builtins.head versionInfo.steam_branches}\"
              - Changing branches is treated as a game update, adding DELTARUNE to Steam's download queue. Wait for the download/update to complete.
              - Go to the game files (Steam Library -> right click DELTARUNE -> Manage -> Browse local files), copy the directory path and use this command to add the game files: nix store add-path --name deltarune GAME_FILES_PATH
            ''
            else if (versionInfo == self.latestPublicVersionInfo)
            then "\n- If you have a newer version installed, you have the possibility of downloading DELTARUNE version ${versionInfo.version} using the Steam console."
            # Only old versions of DELTARUNE on the default "public" branch could/should cover this case
            else "\n- To download old versions of DELTARUNE, you must own DELTARUNE on Steam & use the Steam console."
          )
          + (lib.optionalString (self.isPublicVersion versionInfo) ''
            HOW TO DOWNLOAD DELTARUNE ${versionInfo.version} THROUGH STEAM CONSOLE:
              1. EITHER open steam://open/console -OR- relaunch Steam with the "-console" argument.
              2. In the console's text field, paste the following: download_depot ${builtins.toString metadata.steam_app_id} ${builtins.toString metadata.steam_windows_depot_id} ${versionInfo.steam_windows_manifest_id}
              3. Steam will print "Downloading depot ${builtins.toString metadata.steam_windows_depot_id} (123 files, 456 MB) ..." to the console to indicate it is downloading DELTARUNE ${versionInfo.version}.
              4. Wait for the download to finish. Steam will print the following to the console once its done: "Depot download complete : "/home/USER/.local/share/Steam/ubuntu12_32\steamapps\content\app_${builtins.toString metadata.steam_app_id}\depot_${builtins.toString metadata.steam_windows_depot_id}" (manifest ${versionInfo.steam_windows_manifest_id})"
              5. To add the game files to the Nix store, use the following command: nix store add-path --name deltarune ~/.local/share/Steam/ubuntu12_32/steamapps/content/app_${builtins.toString metadata.steam_app_id}/depot_${builtins.toString metadata.steam_windows_depot_id}
          '')
          + ''
            DOWNLOAD USING DEPOTDOWNLOADER:
            1. Use \"depotdownloader -app ${builtins.toString metadata.steam_app_id} -depot ${builtins.toString metadata.steam_windows_depot_id} -manifest ${versionInfo.steam_windows_manifest_id}${lib.optionalString (!(self.isPublicVersion versionInfo)) " -beta ${builtins.head versionInfo.steam_branches}"}\" with your Steam credentials (\"-username foobar\").
            2. Remove the temporary .DepotDownloader folder with \"rm -r ./depots/${builtins.toString metadata.steam_windows_depot_id}/${builtins.toString versionInfo.steam_buildid}/.DepotDownloader\"
            3. Add executable bit to game assets \"chmod -R +x ./depots/${builtins.toString metadata.steam_windows_depot_id}/${builtins.toString versionInfo.steam_buildid}/.DepotDownloader\"
            4. Add the game files to the Nix store using \"nix store add-path --name deltarune ./depots/${builtins.toString metadata.steam_windows_depot_id}/${builtins.toString versionInfo.steam_buildid}\"
          ''
          + "\n\nRetry this command once the above steps are done. If this error reoccurs, please check https://github.com/MichailiK/deltarune-nix#download-deltarune & ensure you're following the steps carefully.";
      };
  }))
