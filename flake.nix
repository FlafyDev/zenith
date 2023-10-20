{
  description = "";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/ac7c3b5a19a11eda44165053bf8178a2d90f70ec";
    wlroots = {
      url = "gitlab:wlroots/wlroots?host=gitlab.freedesktop.org";
      flake = false;
    };
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
      wlroots-hyprland = pkgs.callPackage ./nix/wlroots.nix {
        version = "git";
        src = inputs.wlroots;
        libdisplay-info = pkgs.libdisplay-info.overrideAttrs (old: {
          version = "0.1.1+date=2023-03-02";
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "emersion";
            repo = old.pname;
            rev = "147d6611a64a6ab04611b923e30efacaca6fc678";
            sha256 = "sha256-/q79o13Zvu7x02SBGu0W5yQznQ+p7ltZ9L6cMW5t/o4=";
          };
        });
        libliftoff = pkgs.libliftoff.overrideAttrs (old: {
          version = "0.5.0-dev";
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "emersion";
            repo = old.pname;
            rev = "d98ae243280074b0ba44bff92215ae8d785658c0";
            sha256 = "sha256-DjwlS8rXE7srs7A8+tHqXyUsFGtucYSeq6X0T/pVOc8=";
          };

          NIX_CFLAGS_COMPILE = toString ["-Wno-error=sign-conversion"];
        });
      };
    in {
      packages = {
        inherit (pkgs) flutter-elinux-engine;
      };
      devShell = pkgs.mkShell {
        env.LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath (with pkgs; [
          fontconfig
        ])}";
        nativeBuildInputs = with pkgs; [
          meson
          pkg-config
        ];
        buildInputs = with pkgs; [
          ninja
          # (builtins.elemAt hyprland.buildInputs 12)
          wlroots-hyprland
          # wlroots
          libglvnd
          libepoxy
          xorg.xcbutilwm
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
          fontconfig
        ];
      };
    })
    // {
      overlays.default = _final: prev: {
        flutter-elinux-engine = prev.callPackage ./nix/flutter-elinux-engine.nix {};
      };
    };
}
