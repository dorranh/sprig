{
  description = "The Nix flake for Sprig. Currently this only provides a dev shell.";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python3.withPackages (ps: with ps; [ grpcio-tools ]);
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.sbt
            pkgs.openjdk_headless
            pkgs.zlib
            pkgs.coursier
            pkgs.graalvm11
            python
            pkgs.poetry
            pkgs.alejandra
          ];

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib"
          '';

        };
      });
}
