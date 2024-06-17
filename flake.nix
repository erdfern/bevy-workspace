{
  description = "A Rust/bevy devshell";

  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, naersk, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        naersk-lib = pkgs.callPackage naersk { };
        bevyDeps = with pkgs; [
          udev
          alsa-lib
          vulkan-loader
          # To use the x11 feature
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          # To use the wayland feature
          libxkbcommon
          wayland
        ];
        rustPkg = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default); # or `toolchain.minimal`
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.pkg-config
          ];
          buildInputs = with pkgs; [
            rustPkg
            taplo
            clang
            mold
            openssl
          ] ++ bevyDeps;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath bevyDeps;
          # shellHook = ''
          # '';
        };
      }
    );
}
