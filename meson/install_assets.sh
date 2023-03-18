#! /usr/bin/env bash

export FLUTTER_ROOT="$(dirname "$(dirname "$(command -v flutter)")")"
export PROJECT_DIR="$(dirname $PWD)"
export DART_OBFUSCATION=false
export TRACK_WIDGET_CREATION=true
export TREE_SHAKE_ICONS=false
export VERBOSE_SCRIPT_LOGGING=true
export PACKAGE_CONFIG="$PROJECT_DIR/.dart_tool/package_config.json"
export FLUTTER_TARGET="$PROJECT_DIR/lib/main.dart"

"$FLUTTER_ROOT/packages/flutter_tools/bin/tool_backend.sh" linux-x64 "$1"

mkdir -p "$MESON_INSTALL_DESTDIR_PREFIX/bin/data"
cp -r "$PROJECT_DIR/build/flutter_assets" "$MESON_INSTALL_DESTDIR_PREFIX/bin/data"
cp -a "$PROJECT_DIR/build/lib/." "$MESON_INSTALL_DESTDIR_PREFIX/lib"
cp "$PROJECT_DIR/linux/flutter/ephemeral/icudtl.dat" "$MESON_INSTALL_DESTDIR_PREFIX/bin/data"
