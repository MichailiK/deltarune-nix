{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    yoyo-games-runner.url = "github:MichailiK/yoyo-games-runner-nix";
  };
  outputs = {
    nixpkgs,
    yoyo-games-runner,
    ...
  }: let
    systems = yoyo-games-runner.supportedSystems;
    forAllSystems = callback:
      nixpkgs.lib.genAttrs systems (
        system: callback nixpkgs.legacyPackages.${system}
      );
    versionMetadata = import ./version-metadata.nix {inherit (nixpkgs) lib;};
  in {
    packages = import ./packages.nix {inherit nixpkgs yoyo-games-runner forAllSystems;};
    inherit versionMetadata;
  };
}
