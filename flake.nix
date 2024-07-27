{
  description = "A Rust/Bevy build env and devshell";
  inputs = {
    fenix.url = "github:nix-community/fenix";
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, fenix, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ fenix.overlays.default ]; # fenix overlay for rust-analyzer-nightly
        pkgs = (import nixpkgs) {
          inherit system overlays;
        };

        toolchain = with fenix.packages.${system};
          combine [
            minimal.rustc
            minimal.cargo
            targets.x86_64-unknown-linux-gnu.latest.rust-std
            targets.x86_64-unknown-linux-musl.latest.rust-std
            targets.x86_64-pc-windows-gnu.latest.rust-std
          ];

        naersk' = naersk.lib.${system}.override {
          cargo = toolchain;
          rustc = toolchain;
        };

        naerskBuildPackage = target: args:
          naersk'.buildPackage (
            args
            // { CARGO_BUILD_TARGET = target; }
            // cargoConfig
          );

        # All of the CARGO_* configurations which should be used for all
        # targets.
        #
        # Only use this for options which should be universally applied or which
        # can be applied to a specific target triple.
        #
        # This is also merged into the devShell.
        cargoConfig = {
          # Tells Cargo to enable static compilation.
          # (https://doc.rust-lang.org/cargo/reference/config.html#targettriplerustflags)
          #
          # Note that the resulting binary might still be considered dynamically
          # linked by ldd, but that's just because the binary might have
          # position-independent-execution enabled.
          # (see: https://github.com/rust-lang/rust/issues/79624#issuecomment-737415388)
          # CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS = "-C target-feature=+crt-static";

          # Tells Cargo that it should use Wine to run tests.
          # (https://doc.rust-lang.org/cargo/reference/config.html#targettriplerunner)
          CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUNNER = pkgs.writeScript "wine-wrapper" ''
            export WINEPREFIX="$(mktemp -d)"
            exec wine64 $@
          '';
        };

        bevyDeps = with pkgs; [
          alsa-lib
          udev
          openssl
          vulkan-loader
          # vulkan-headers
          # vulkan-validation-layers
          # To use the x11 feature
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          # To use the wayland feature
          libxkbcommon
          wayland
        ];
      in
      rec {
        defaultPackage = packages.x86_64-unknown-linux-gnu;

        # For `nix build .#x86_64-unknown-linux-gnu`:
        packages.x86_64-unknown-linux-gnu = naerskBuildPackage "x86_64-unknown-linux-gnu" {
          src = ./.;
          doCheck = true;
          nativeBuildInputs = with pkgs; [ pkgsStatic.stdenv.cc pkgs.pkg-config ];
          buildInputs = bevyDeps;
        };

        # For `nix build .#x86_64-unknown-linux-musl`: TODO
        packages.x86_64-unknown-linux-musl = naerskBuildPackage "x86_64-unknown-linux-musl" {
          src = ./.;
          doCheck = true;
          nativeBuildInputs = with pkgs; [
            pkgsStatic.stdenv.cc
            pkg-config
            clang
            mold
          ];
          buildInputs = bevyDeps;
        };

        # For `nix build .#x86_64-pc-windows-gnu`: TODO
        packages.x86_64-pc-windows-gnu = naerskBuildPackage "x86_64-pc-windows-gnu" {
          src = ./.;
          doCheck = true;
          strictDeps = true;

          depsBuildBuild = with pkgs; [
            pkgsCross.mingwW64.stdenv.cc
            pkgsCross.mingwW64.windows.pthreads
          ];

          nativeBuildInputs = with pkgs; [
            # We need Wine to run tests:
            wineWowPackages.stable
          ];
        };

        devShell = pkgs.mkShell (
          {
            inputsFrom = with packages; [ x86_64-unknown-linux-gnu x86_64-unknown-linux-musl x86_64-pc-windows-gnu ];
            CARGO_BUILD_TARGET = "x86_64-unknown-linux-gnu";

            buildInputs = with pkgs; [
              # complete rust distribution for the devshell, with clippy and such :3
              (fenix.packages.${system}.complete.withComponents [
                "cargo"
                "clippy"
                "rust-src"
                "rustc"
                "rustfmt"
              ])
              rust-analyzer-nightly
              taplo
              #   vulkan-tools
            ];
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath bevyDeps;
          } // cargoConfig
        );
      }
    );
}
