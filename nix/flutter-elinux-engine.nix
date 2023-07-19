{
  stdenvNoCC,
  flutter,
  wget,
  system,
  unzip,
  lib,
}: let
  inherit (lib) last splitString concatStringsSep;
  flutter' = flutter.override {
    supportsAndroid = false;
  };

  arch =
    {
      aarch64 = "arm64";
      x86_64-linux = "x64";
    }
    .${system};
  libs = stdenvNoCC.mkDerivation {
    pname = "flutter-elinux-engine-libraries";
    inherit (flutter) version;
    dontUnpack = true;
    nativeBuildInputs = [wget unzip];
    installPhase =
      ''
        mkdir -p $out/lib;
        export ENGINE_SHORT_REVISION=$(head -c 10 ${flutter'}/bin/internal/engine.version);
      ''
      + (concatStringsSep "\n" (map (artifact: let
          type = last (splitString "-" artifact);
        in ''
          wget https://github.com/sony/flutter-embedded-linux/releases/download/$ENGINE_SHORT_REVISION/${artifact}.zip --no-check-certificate
          unzip ./${artifact}.zip -d ${artifact}
          cp ${artifact}/libflutter_engine.so $out/lib/libflutter_engine_${type}.so
          ls -lA $out/lib/
        '') [
          "elinux-${arch}-debug"
          "elinux-${arch}-profile"
          "elinux-${arch}-release"
        ]));
    outputHash = "sha256-IwiisHS6dpfJjgO0WxBawDK1BDhU/Nx8Z0QMYczdnY0=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "flutter-elinux-engine";
    inherit (flutter) version;
    dontUnpack = true;

    installPhase =
      ''
        mkdir -p $out/lib/pkgconfig/
        cp -r ${libs}/* $out/

      ''
      + (concatStringsSep "\n" (map (type: ''
        cat << EOF > $out/lib/pkgconfig/libflutter-engine-${type}.pc
        prefix=$out
        libdir=$out/lib
        includedir=$out/include

        Name: flutter_engine_${type}
        Description: Flutter eLinux Engine
        Version: ${flutter.version}
        Libs: -L$out/lib -lflutter_engine_${type}
        Cflags: -I$out/include
        EOF
      '') ["debug" "profile" "release"]));
  }
