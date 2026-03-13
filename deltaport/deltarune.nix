{
  # Arguments
  src,
  version ? null,
  mkYoYoGamesRunner,
  # nixpkgs inputs
  pkgs,
  lib,
  ...
}: let
  deltaport = pkgs.callPackage ./deltaport.nix {};
  assets = pkgs.callPackage ./deltarune-assets-patched.nix {inherit src version deltaport;};
  gameSwitchHelper = pkgs.callPackage ./deltarune-game-switch-helper.nix {};
  wrappedRunner = mkYoYoGamesRunner {
    system = "x86_64-linux";
    name = "deltarune";
    src = "${deltaport}/deltarune";
    version = version + "+deltaport";
    gameAssets = assets;
    includeFFmpeg = true; # Chapter 3 contains video
  };
in
  wrappedRunner.overrideAttrs (final: prev: {
    # This adds the game switch helper script & Copy the yoyo games runner
    # binary to every chapter folder.
    # DELTARUNE makes use of `game_change` in GameMaker, and stores the assets
    # of each chapter in its own directory.
    # Unfortunately, the dated yoyo games linux runner used for DELTARUNE
    # is hardcoded to read game.unx & other assets in the directory its binary
    # is present in. So we must copy the binary to every chapter.
    # For more info see:
    # - https://manual.gamemaker.io/beta/en/GameMaker_Language/GML_Reference/General_Game_Control/game_change.htm
    # - https://github.com/YoYoGames/GameMaker-Bugs/issues/7225
    meta.mainProgram = "deltarune.sh";
    postInstall =
      (prev.postInstall or "")
      + ''
        ln -s "${lib.getExe gameSwitchHelper}" "$out"/bin/deltarune.sh

        chmod +w "$out"/bin/chapter*_linux
        cp "$out"/bin/deltarune "$out"/bin/chapter1_linux/
        cp "$out"/bin/deltarune "$out"/bin/chapter2_linux/
        cp "$out"/bin/deltarune "$out"/bin/chapter3_linux/
        cp "$out"/bin/deltarune "$out"/bin/chapter4_linux/
      '';
  })
