{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-25.05";
    yoyo-games-runner.url = "github:MichailiK/yoyo-games-runner-nix";
  };
  outputs =
    { nixpkgs, yoyo-games-runner, ... }:
    let
      # only 64-bit Linux systems are supported for now
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      forEachDeltaruneChapter =
        callback:
        pkgs.lib.mergeAttrsList (
          pkgs.lib.forEach [
            "1"
            "2"
            "3"
            "4"
          ] (chapter: callback chapter)
        );

      deltaruneVersion = "1.01C";
      deltaruneDefaultPkg = pkgs.callPackage ./deltarune.nix {
        inherit (yoyo-games-runner) mkYoYoGamesRunner;
        deltaruneAssets = import ./deltarune-assets.nix;
        deltaruneGameSwitchHelper = import ./deltarune-game-switch-helper.nix;
        deltaport = import ./deltaport;

        version = deltaruneVersion;
        src = pkgs.requireFile {
          name = "deltarune";
          sha256 = "sha256-Ho1h4e96ot17IE7Y0APxhbfOm7t2zQyWw7jUt0ndQ9k=";
          hashMode = "recursive";
          message = ''
            A copy of DELTARUNE v${deltaruneVersion} must be added to the Nix store.
            Instructions on how to obtain a copy of DELTARUNE and add it to the
            Nix store are available in the README of the deltarune-nix repository
            (https://github.com/MichailiK/deltarune-nix#download-deltarune)
          '';
        };
      };
    in
    {

      packages.${system} =
        {
          default = deltaruneDefaultPkg;
        }
        // forEachDeltaruneChapter (chapter: {

          "ch${chapter}" = pkgs.writeShellApplication {
            name = "deltarune-ch${chapter}";
            text = "${deltaruneDefaultPkg}/bin/chapter${chapter}_linux/deltarune";
          };

          "ch${chapter}-libtas" = pkgs.writeShellApplication {
            name = "deltarune-ch${chapter}-libtas";
            runtimeInputs = [ pkgs.libtas ];
            # Forcing libTAS to use X11 as Wayland support is not great
            text = ''QT_QPA_PLATFORM=xcb libTAS "${deltaruneDefaultPkg}/bin/chapter${chapter}_linux/deltarune"'';
          };
        });

      # Allows creating a Deltarune derivation using a custom source
      mkDeltarune =
        {
          src,
          version ? null,
          ...
        }@inputs:
        pkgs.callPackage ./deltarune.nix inputs
        // {
          inherit src version;
          inherit (yoyo-games-runner) mkYoYoGamesRunner;
          deltaruneAssets = import ./deltarune-assets.nix;
          deltaruneGameSwitchHelper = import ./deltarune-game-switch-helper.nix;
          deltaport = import ./deltaport;
        };
    };
}
