{
  description = "";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in {
      packages = {
        inherit (pkgs) flutter-elinux-engine;
      };
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          meson
          pkg-config
        ];
        buildInputs = with pkgs; [
          ninja
          wlroots
          libglvnd
          libepoxy
          wayland
          libxkbcommon
          pixman
          libinput
          yq
          pam
          cairo
          libdrm
          flutter-elinux-engine
          (flutter.override {
            supportsAndroid = false;
          })
        ];
      };
    })
    // {
      overlays.default = _final: prev: {
        flutter-elinux-engine = prev.callPackage ./nix/flutter-elinux-engine.nix {};
      };
    };
}
