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
        packages =
          [
            # pkgs.cargo
            pkgs.libiconv # Required for cargo builds on MacOS
            # pkgs.rustfmt
            pkgs.just
            pkgs.python3
            pkgs.poetry
            pkgs.alejandra
            pkgs.nodejs_21
          ]
          ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [pkgs.darwin.apple_sdk.frameworks.Security]);

        shellHook = ''
          export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib";
        '';
      };
    });
}
