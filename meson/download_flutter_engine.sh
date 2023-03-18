#! /usr/bin/env bash

export ENGINE_REVISION="$1"
export ARCH="$2"
export TYPE="$3"

wget -O "/tmp/elinux-x64-${TYPE}.zip" "https://github.com/sony/flutter-embedded-linux/releases/download/${ENGINE_REVISION}/elinux-${ARCH}-${TYPE}.zip"
unzip -o "/tmp/elinux-x64-${TYPE}.zip" -d /tmp
mv /tmp/libflutter_engine.so "libflutter_engine_${TYPE}_${ARCH}_${ENGINE_REVISION}.so"

