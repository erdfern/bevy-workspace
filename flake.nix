# interesting: https://github.com/Lemin-n/Cranix
# https://github.com/ipetkov/crane
{
  description = "A Rust/Bevy project template and devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , fenix
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let

        overlays = [ fenix.overlays.default ]; # fenix overlay for rust-analyzer-nightly
        pkgs = (import nixpkgs) {
          inherit system overlays;
        };

        rust-toolchain = (fenix.packages.${system}.complete.withComponents [
          "cargo"
          "clippy"
          "rust-src" # RUST_SRC_PATH = "${fenix.complete.rust-src}/lib/rustlib/src/rust/library"
          "rustc"
          "rustfmt"
          "rustc-codegen-cranelift-preview" # for cranelift backend
        ]);
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            # CARGO_BUILD_TARGET = "x86_64-unknown-linux-gnu";

            # In devshell, distinction between nativeBuildInputs and buildInputs doesn't matter, but alas it might remind me where stuff goes if I were to add package builds
            # https://gist.github.com/CMCDragonkai/45359ee894bc0c7f90d562c4841117b5
            # Dependencies that should be _only_ in the _build_ environment
            nativeBuildInputs = [
              # Rust dependencies
              pkg-config
              # (rust-bin.stable.latest.default.override { extensions = [ "rust-src" ]; })
              rust-toolchain
              rust-analyzer-nightly
              # vscode-extensions.rust-lang.rust-analyzer-nightly

              # for mold linking
              pkgsStatic.stdenv.cc
              clang
              mold
            ];
            # Dependencies that should be in the _runtime_ environment
            buildInputs =
              [
              ]
              ++ lib.optionals (lib.strings.hasInfix "linux" system) [
                # for Linux
                # Audio (Linux only)
                alsa-lib
                # Cross Platform 3D Graphics API
                vulkan-loader
                # For debugging around vulkan
                vulkan-tools
                # Other dependencies
                libudev-zero
                xorg.libX11
                xorg.libXcursor
                xorg.libXi
                xorg.libXrandr
                libxkbcommon
                # Required for the wayland feature
                wayland
              ];
            # RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              vulkan-loader
              xorg.libX11
              xorg.libXi
              xorg.libXcursor
              libxkbcommon
            ];
          };
      }
    );
}
