{
  description = "The Nix flake for Sprig. Currently this only provides a dev shell.";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        packages = [pkgs.sbt pkgs.alejandra pkgs.openjdk_headless pkgs.zlib pkgs.graalvm11 pkgs.coursier];
      };
    });
}
