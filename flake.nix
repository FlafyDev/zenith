{
  description = "";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    dart-flutter.url = "path:/mnt/general/repos/flafydev/dart-flutter-nix";
  };

  outputs = { self, flake-utils, nixpkgs, dart-flutter, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          dart-flutter.overlays.default
          self.overlays.default
        ];
      }; 
    in {
      packages = {
        inherit (pkgs) flutter-elinux-engine;
      };
      devShell = pkgs.mkFlutterShell {
        nativeBuildInputs = with pkgs; [
          meson
          pkg-config
        ];
        buildInputs = with pkgs; [
          wlroots
          libglvnd
          libepoxy
          wayland
          libxkbcommon
          pixman
          libinput
          yq
          pam
          libdrm
          flutter-elinux-engine
        ];
        linux.enable = true;
      };
    }) // {
      overlays.default = _final: prev: {
        flutter-elinux-engine = prev.callPackage ./nix/flutter-elinux-engine.nix { };
      };
    }; 
}

