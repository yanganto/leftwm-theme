{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, rust-overlay, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust = pkgs.rust-bin.stable.latest.default;
      in
      with pkgs;
      rec {
        packages.${system}.leftwm-theme = pkgs.rustPlatform.buildRustPackage {
          name = "leftwm-theme";
          src = self;
          cargoSha256 = "sha256-v2OjedWuxkErBuC4EFwFY91pw8yT1Vt8HSYmrNPsQ1I=";
          buildInputs = [ openssl ];
          nativeBuildInputs = [ pkg-config ];
          checkFlags = [
            # direct writing /tmp
            "--skip=models::config::test::test_config_new"
            # with network access when testing
            "--skip=operations::update::test::test_update_repos"
          ];
        };
        defaultPackage = packages.${system}.leftwm-theme;
        devShell = mkShell {
          buildInputs = [
            rust
            openssl
            pkg-config
          ];
        };
      }
    );
}
